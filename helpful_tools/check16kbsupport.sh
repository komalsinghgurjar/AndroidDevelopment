#!/system/bin/sh
# POSIX-compliant script (NO bash features)

set -eu

#################################
# CONFIG
#################################

AAB_FILE="app-release.aab"
BUNDLETOOL_JAR="bundletool.jar"
BUNDLETOOL_VERSION="1.18.3"

NDK_LLVM_OBJDUMP="/data/data/com.termux/files/home/android-ndk-r27b/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-objdump"

WORKDIR="./_16kb_check_tmp"

#################################
# PRECHECKS
#################################

if [ ! -f "$AAB_FILE" ]; then
  echo "ERROR: $AAB_FILE not found"
  exit 1
fi

if [ ! -x "$NDK_LLVM_OBJDUMP" ]; then
  echo "ERROR: llvm-objdump not found at:"
  echo "$NDK_LLVM_OBJDUMP"
  exit 1
fi

#################################
# DOWNLOAD BUNDLETOOL IF NEEDED
#################################

if [ ! -f "$BUNDLETOOL_JAR" ]; then
  echo "Downloading bundletool $BUNDLETOOL_VERSION ..."
  curl -L -o "$BUNDLETOOL_JAR" \
    "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar"
fi

#################################
# CHECK AAB ZIP ALIGNMENT
#################################

echo
echo "=============================="
echo "AAB ZIP PAGE ALIGNMENT CHECK"
echo "=============================="

if java -jar "$BUNDLETOOL_JAR" dump config --bundle="$AAB_FILE" | grep -q "PAGE_ALIGNMENT_16K"; then
  echo "PASS: AAB requests PAGE_ALIGNMENT_16K"
else
  echo "FAIL: AAB does NOT request 16 KB zip alignment"
  exit 1
fi

#################################
# EXTRACT .so FILES
#################################

echo
echo "=============================="
echo "EXTRACTING NATIVE LIBRARIES"
echo "=============================="

rm -rf "$WORKDIR"
mkdir "$WORKDIR"

unzip -q "$AAB_FILE" "base/lib/*/*.so" -d "$WORKDIR" || true

SO_LIST=$(find "$WORKDIR" \
  \( -path "*/arm64-v8a/*.so" -o -path "*/x86_64/*.so" \) 2>/dev/null)


if [ -z "$SO_LIST" ]; then
  echo "INFO: No native libraries found"
  rm -rf "$WORKDIR"
  exit 0
fi

#################################
# ELF ALIGNMENT CHECK
#################################

echo
echo "=============================="
echo "ELF LOAD SEGMENT ALIGNMENT"
echo "=============================="

FAIL=0

for so in $SO_LIST; do
  name=$(basename "$so")
  echo
  echo ">>> $name"

  LOAD_OUTPUT=$("$NDK_LLVM_OBJDUMP" -p "$so" | grep LOAD)
  echo "$LOAD_OUTPUT"

  if echo "$LOAD_OUTPUT" | grep -q "2\\*\\*1[0-3]"; then
    echo "FAIL: $name has < 16 KB ELF alignment"
    FAIL=1
  else
    echo "PASS: $name is fully 16 KB aligned"
  fi
done

#################################
# CLEANUP
#################################

rm -rf "$WORKDIR"

#################################
# FINAL RESULT
#################################

echo
echo "=============================="
echo "FINAL RESULT"
echo "=============================="

if [ "$FAIL" -ne 0 ]; then
  echo "NOT 16 KB COMPATIBLE"
  echo "Rebuild failing native libraries with:"
  echo "NDK r27+ and ANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
  exit 1
else
  echo "FULLY 16 KB COMPATIBLE"
  echo "Safe for Android 15+ and Google Play (Nov 2025)"
  exit 0
fi

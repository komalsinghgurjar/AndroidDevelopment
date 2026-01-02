#!/usr/bin/env bash

# invoke from the root of project dir

set -euo pipefail

echo "======================================"
echo " Android Release Artifacts Script"
echo "======================================"
echo

# Must be run from project root
if [[ ! -f "gradlew" ]]; then
    echo "ERROR: gradlew not found."
    echo "Run this script from Android project root."
    exit 1
fi

export GRADLE_OPTS="-Dorg.gradle.wrapper.timeout=300000"

echo "[INFO] Killing any stale Gradle processes (if any)..."
pkill -f gradle || true
echo

echo "[STEP] assembleRelease"
echo "--------------------------------------"
bash gradlew assembleRelease --no-daemon
echo

echo "[STEP] bundleRelease"
echo "--------------------------------------"
bash gradlew bundleRelease --no-daemon
echo

echo "[STEP] Copying release artifacts to project root"
echo "--------------------------------------"
find app/build/outputs/apk -type f -name "*release*.apk" -print -exec cp -v {} . \;
find app/build/outputs/bundle -type f -name "*release*.aab" -print -exec cp -v {} . \;
echo

# Detect artifacts
AAB_FILE=$(ls *.aab 2>/dev/null | head -n 1 || true)
APK_FILE=$(ls *unsigned*.apk 2>/dev/null | head -n 1 || true)

# --------------------------------------------------
# Keystore selection
# --------------------------------------------------

echo "[STEP] Detecting signing key files in current directory"
echo "--------------------------------------"

mapfile -t KEY_FILES < <(
    ls *.keystore *.jks *.p12 *.pfx *.pkcs12 2>/dev/null || true
)

if [[ ${#KEY_FILES[@]} -eq 0 ]]; then
    echo "ERROR: No keystore files found in current directory."
    exit 1
fi

echo "Available keystore files:"
for i in "${!KEY_FILES[@]}"; do
    printf "  [%d] %s\n" "$((i+1))" "${KEY_FILES[$i]}"
done

echo
read -p "Choose keystore number: " KS_INDEX
KS_INDEX=$((KS_INDEX-1))

KEYSTORE="${KEY_FILES[$KS_INDEX]}"

if [[ ! -f "$KEYSTORE" ]]; then
    echo "ERROR: Invalid keystore selection."
    exit 1
fi

echo
echo "[INFO] Selected keystore: $KEYSTORE"
echo

# --------------------------------------------------
# Alias selection
# --------------------------------------------------

echo "[STEP] Reading aliases from keystore"
echo "--------------------------------------"

keytool -list -keystore "$KEYSTORE"

echo
read -p "Enter key alias to use: " KEY_ALIAS

if [[ -z "$KEY_ALIAS" ]]; then
    echo "ERROR: Alias cannot be empty."
    exit 1
fi

echo

# --------------------------------------------------
# Sign AAB
# --------------------------------------------------

if [[ -n "$AAB_FILE" ]]; then
    echo "[STEP] Signing AAB: $AAB_FILE"
    echo "--------------------------------------"
    jarsigner -verbose \
        -sigalg SHA256withRSA \
        -digestalg SHA-256 \
        -keystore "$KEYSTORE" \
        "$AAB_FILE" "$KEY_ALIAS"
    echo
else
    echo "[WARN] No .aab found to sign"
    echo
fi

# --------------------------------------------------
# Sign APK
# --------------------------------------------------

if [[ -n "$APK_FILE" ]]; then
    echo "[STEP] Signing APK: $APK_FILE"
    echo "--------------------------------------"
    apksigner sign \
        --ks "$KEYSTORE" \
        --ks-key-alias "$KEY_ALIAS" \
        "$APK_FILE"
    echo
else
    echo "[WARN] No unsigned APK found to sign"
    echo
fi

echo "======================================"
echo " DONE – Release Artifacts Ready"
echo "======================================"

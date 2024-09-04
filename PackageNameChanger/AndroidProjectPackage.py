import os
import re
import argparse

class AndroidProjectPackage:
    class BuildFileNotFoundError(FileNotFoundError):
        pass

    class PatternNotFoundError(ValueError):
        pass

    @staticmethod
    def find_build_file(project_root):
        project_root = os.path.abspath(project_root)
        build_files = ['build.gradle', 'build.gradle.kts']
        for file_name in build_files:
            file_path = os.path.join(project_root, 'app', file_name)
            if os.path.exists(file_path):
                return file_path
        raise AndroidProjectPackage.BuildFileNotFoundError("Neither build.gradle nor build.gradle.kts file found in the 'app' directory.")

    @staticmethod
    def extract_value(file_path, pattern):
        try:
            with open(file_path, 'r') as file:
                for line in file:
                    match = pattern.search(line)
                    if match:
                        return match.group(1)
            raise AndroidProjectPackage.PatternNotFoundError(f"Pattern not found in file: {file_path}")
        except FileNotFoundError as e:
            raise AndroidProjectPackage.BuildFileNotFoundError(f"File not found: {file_path}") from e

    @staticmethod
    def extract_namespace(project_root):
        build_file_path = AndroidProjectPackage.find_build_file(project_root)
        namespace_pattern = re.compile(r'namespace\s*[=:]\s*[\'"]([^\'"]+)[\'"]')
        return AndroidProjectPackage.extract_value(build_file_path, namespace_pattern)

    @staticmethod
    def extract_application_id(project_root):
        build_file_path = AndroidProjectPackage.find_build_file(project_root)
        application_id_pattern = re.compile(r'applicationId\s*[=:]\s*[\'"]([^\'"]+)[\'"]')
        return AndroidProjectPackage.extract_value(build_file_path, application_id_pattern)

    @staticmethod
    def is_same_namespace_and_application_id(project_root):
        try:
            namespace = AndroidProjectPackage.extract_namespace(project_root)
            application_id = AndroidProjectPackage.extract_application_id(project_root)

            if namespace == application_id:
                return namespace
            else:
                return False
        
        except (AndroidProjectPackage.BuildFileNotFoundError, AndroidProjectPackage.PatternNotFoundError) as e:
            AndroidProjectPackage.print_error(e)
            return None
        except Exception as e:
            AndroidProjectPackage.print_error(f"An unexpected error occurred: {e}")
            return None

    @staticmethod
    def print_error(message):
        print(f"Error: {message}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Validate Android project namespace and applicationId.")
    parser.add_argument("project_root", help="Path to the root of the Android project.")
    args = parser.parse_args()

    package_name = AndroidProjectPackage.is_same_namespace_and_application_id(args.project_root)
    print(f"Same Package Name & Application Id: {package_name}")

    namespace = AndroidProjectPackage.extract_namespace(args.project_root)
    print(f"Namespace Found: {package_name}")
    
    application_id = AndroidProjectPackage.extract_application_id(args.project_root)
    print(f"Application Id Found: {application_id}")

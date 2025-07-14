import os

# Path to the main directory
main_directory = 'checks'
failed_tests = []
passed_tests = []
# Iterate through each directory in the main directory
for dirpath, dirnames, filenames in os.walk(main_directory):
    # Check if 'FAIL' is in the filenames
    if 'FAIL' in filenames:
        failed_tests.append(dirpath)
    if 'PASS' in filenames:
        passed_tests.append(dirpath)
print("Passed checks:")
for test in passed_tests:
    print(test)
print("Failed checks:")
for test in failed_tests:
    print(test)

ATTENDANCE TRACKER BOOTSTRAP PROJECT.

PROJECT OVERVIEW.

This project contains a shell script that automates the setup of an attendance tracking system. The script creates a complete project directory with all necessary files, configurable thresholds, and includes safety features for handling interruptions.

What the Script Does:

1. Creates a project folder named attendance_tracker_[suffix] where [suffix] is provided by the user
2. Sets up the required directory structure with Helpers and reports subfolders
3. Populates all four required files with their exact content from the assignment
4. Optionally updates attendance warning and failure thresholds using sed
5. Validates user input to ensure thresholds are numbers
6. Checks if Python 3 is installed on the system
7. Handles Ctrl+C interruptions by archiving the current state and cleaning up

How to Run the Script.
1. Make the script executable: chmod +x setup_project.sh
2. Run the script: ./setup_project.sh
3. Follow the prompts:
Enter a suffix for your project (example: v1, test, project1)
Decide if you want to update attendance thresholds
If updating, enter new percentage values for warning and failure thresholds

How to Trigger the Archive Feature.
The archive feature activates automatically when you press Ctrl+C during script execution. This can happen at any point:

While being prompted for input
During directory creation
While files are being generated

When triggered, the script will:

1. Create a compressed archive named attendance_tracker_[suffix]_archive.tar.gz containing whatever part of the project was already created
2. Delete the incomplete project directory to keep your workspace clean
3. Exit gracefully

Files Created
After successful execution, you will find:

1. attendance_tracker_[suffix]/attendance_checker.py - The main Python application
2. attendance_tracker_[suffix]/Helpers/assets.csv - Student attendance data
3. attendance_tracker_[suffix]/Helpers/config.json - Configuration with thresholds
4. attendance_tracker_[suffix]/reports/reports.log - Sample attendance reports

Requirements:

1. Bash shell (Linux, macOS, or Windows with WSL)
2. Python 3 (optional but recommended for running the attendance tracker)

Notes

1. The script will not overwrite existing directories but will use them if they already exist
2. Default thresholds are 75% for warning and 50% for failure
3. Invalid threshold inputs automatically revert to default values
4. The Python check is informational only and does not stop the script

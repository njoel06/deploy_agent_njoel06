#!/bin/bash
# Automated Project Bootstrapping Script

# Function to handle Ctrl+C interrupt
cleanup() {
	echo ""
	echo "Script interrupted! Cleaning up"

	# Archive if directory exists
	if [ -d "$base_dir" ]; then
		tar -czf "attendance_tracker_${suffix}_archive.tar.gz" "$base_dir"
		rm -rf "$base_dir"
		echo "Archived and removed $base_dir"
	fi

	exit 1
  
  }
# Set the trap
trap cleanup SIGINT

# Get suffix
echo "Enter suffix:"
read suffix
base_dir="attendance_tracker_${suffix}"

# Create structure
mkdir -p "$base_dir/Helpers" "$base_dir/reports"

# Create files (using heredocs)
cat > "$base_dir/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat > "$base_dir/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat > "$base_dir/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

cat > "$base_dir/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

# Optional: update thresholds
echo "Update thresholds? (y/n)"
read answer
if [ "$answer" = "y" ]; then
	# Getting warning threshold
	while true; do 
		 echo "New warning % (default 75):"
		 read warning
		 # If empty use default
		 if [ -z "$warning" ]; then
			 warning = 75
			 break
		fi
		# Check if it's a number
		if [[ "$warning" =~ ^[0-9]+$ ]]; then
			break
		else
			echo " Error: Please enter a number (e.g., 80)"
		fi
	done

	# Get failure threshold 
	while true; do
		echo "New failure % (default 50):"
		read failure
		#if empty use default
		if [ -z "$failure" ]; then
			failure = 50
			break
		fi
		#check if it's a number
		if [[ "$failure" =~ ^[0-9]+$ ]]; then
			break
		else
			echo " Error: Please enter a number (e.g., 60)"
		fi
	done
	 # Update the config file
	 sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$base_dir/Helpers/config.json"
	 sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$base_dir/Helpers/config.json"
	 echo " Thresholds updated: warning=$warning%, failure=$failure%"

fi
# Check Python
if command -v python3 &>/dev/null; then
	echo "Python 3 found: $(python3 --version)"
else
	echo "Warning: Python 3 not found"
fi

echo "Done!"

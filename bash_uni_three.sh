#!/bin/bash

SUBMISSION_FILE="submissions.txt"
SUBMISSION_LOG="submission_log.txt"
LOGIN_LOG="login_log.txt"
LOCKED_FILE="locked_accounts.txt"

touch "$SUBMISSION_FILE" "$SUBMISSION_LOG" "$LOGIN_LOG" "$LOCKED_FILE"

# =========================
# Part 2: File Validation
# =========================
validate_file() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "File does not exist."
        return 1
    fi

    extension="${file##*.}"
    extension=$(echo "$extension" | tr 'A-Z' 'a-z')

    if [[ "$extension" != "pdf" && "$extension" != "docx" ]]; then
        echo "Invalid file type. Only .pdf and .docx files are allowed."
        return 1
    fi

    size=$(stat -c%s "$file")

    if [ "$size" -gt 5242880 ]; then
        echo "File is too large. Maximum size is 5MB."
        return 1
    fi

    return 0
}

# =========================
# Part 3: Duplicate Submission Detection
# =========================
submit_assignment() {
    local file="$1"
    local filename
    local filehash

    filename=$(basename "$file")
    filehash=$(sha256sum "$file" | awk '{print $1}')

    if grep -q "^$filename|$filehash$" "$SUBMISSION_FILE"; then
        echo "Duplicate submission rejected."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - REJECTED DUPLICATE - $filename" >> "$SUBMISSION_LOG"
        return 1
    fi

    echo "$filename|$filehash" >> "$SUBMISSION_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - SUBMITTED - $filename" >> "$SUBMISSION_LOG"
    echo "File submitted successfully."
    return 0
}

check_submission() {
    read -p "Enter filename to check: " checkfile

    if grep -q "^$checkfile|" "$SUBMISSION_FILE"; then
        echo "File has already been submitted."
    else
        echo "File has not been submitted."
    fi
}

list_submissions() {
    echo "List of submitted assignments:"
    if [ -s "$SUBMISSION_FILE" ]; then
        cat "$SUBMISSION_FILE"
    else
        echo "No submissions found."
    fi
}

# =========================
# Part 4: Access Control and Suspicious Activity Detection
# =========================
simulate_login() {
    read -p "Enter username: " username
    current_time=$(date +%s)

    if grep -q "^$username$" "$LOCKED_FILE"; then
        echo "Account is locked."
        echo "$username|$current_time|LOCKED" >> "$LOGIN_LOG"
        return
    fi

    read -p "Enter password: " password

    recent_attempts=$(awk -F'|' -v user="$username" -v now="$current_time" '
        $1 == user && (now - $2) <= 60 {count++}
        END {print count+0}
    ' "$LOGIN_LOG")

    if [ "$recent_attempts" -ge 3 ]; then
        echo "Suspicious activity detected: repeated login attempts within 60 seconds."
    fi

    if [ "$password" = "admin123" ]; then
        echo "Login successful."
        echo "$username|$current_time|SUCCESS" >> "$LOGIN_LOG"
    else
        echo "Login failed."
        echo "$username|$current_time|FAILED" >> "$LOGIN_LOG"

        failed_attempts=$(awk -F'|' -v user="$username" '
            $1 == user && $3 == "FAILED" {count++}
            END {print count+0}
        ' "$LOGIN_LOG")

        if [ "$failed_attempts" -ge 3 ]; then
            grep -q "^$username$" "$LOCKED_FILE" || echo "$username" >> "$LOCKED_FILE"
            echo "Account locked after three failed login attempts."
        fi
    fi
}

# =========================
# Part 1: Menu System
# =========================
while true
do
    echo ""
    echo "===== Secure Examination Submission and Access Control System ====="
    echo "1. Submit an assignment"
    echo "2. Check if a file has already been submitted"
    echo "3. List all submitted assignments"
    echo "4. Simulate login attempt"
    echo "5. Exit system"
    echo ""

    read -p "Choose an option: " choice

    case $choice in
        1)
            read -p "Enter file path: " file
            if validate_file "$file"; then
                submit_assignment "$file"
            fi
            ;;

        2)
            check_submission
            ;;

        3)
            list_submissions
            ;;

        4)
            simulate_login
            ;;

        5)
            read -p "Are you sure you want to exit? (y/n): " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                echo "Exiting system..."
                break
            else
                echo "Exit cancelled."
            fi
            ;;

        *)
            echo "Invalid option. Please choose between 1 and 5."
            ;;
    esac
done
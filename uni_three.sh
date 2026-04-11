#!/bin/bash

SUBMISSION_FILE="submissions.txt"
SUBMISSION_LOG="submission_log.txt"

#part 2
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

#part 3
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



#part 1
while true
do
    echo ""
    echo " Secure Examination Submission and Access Control System "
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
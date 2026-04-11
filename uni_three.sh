#!/bin/bash

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
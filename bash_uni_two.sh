#!/bin/bash

while true
do
    echo ""
    echo "===== Job Scheduling System ====="
    echo "1. View pending jobs"
    echo "2. Submit a job request"
    echo "3. Process job queue"
    echo "4. View completed jobs"
    echo "5. Exit"

    read -p "Choose an option: " choice

    case $choice in
        1)
            echo "View pending jobs"
            ;;
        2)
            echo "Submit a job request"
            ;;
        3)
            echo "Process job queue using Round Robin or Priority scheduling"
            ;;
        4)
            echo "View completed jobs"
            ;;
        5)
            read -p "Are you sure you want to exit? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                echo "Goodbye!"
                break
            else
                echo "Exit cancelled."
            fi
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
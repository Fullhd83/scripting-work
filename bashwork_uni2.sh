#!/bin/bash


# Part 1: User Menu
while true
do
    echo ""
    echo "### Job Scheduling System ###"
    echo "1. View pending jobs"
    echo "2. Submit a job request"
    echo "3. Process job queue"
    echo "4. View completed jobs"
    echo "5. Exit"

    read -p "Choose an option: " choice

    case $choice in
        1)
            view_pending_jobs
            ;;
        2)
            submit_job
            ;;
        3)
            process_queue
            ;;
        4)
            view_completed_jobs
            ;;
        5)
            read -p "Are you sure you want to exit? (y/n): " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
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
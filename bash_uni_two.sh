#!/bin/bash

QUEUE_FILE="job_queue.txt"
COMPLETED_FILE="completed_jobs.txt"
LOG_FILE="scheduler_log.txt"

touch $QUEUE_FILE $COMPLETED_FILE $LOG_FILE

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
            echo ""
            echo "View pending jobs"
            cat "$QUEUE_FILE"
            ;;
        2)
            echo ""
            read -p "Enter student ID: " student_id
            read -p "Enter job name: " job_name
            read -p "Enter execution time: " exec_time
            read -p "Enter job priority (1-10): " priority

            echo "$student_id,$job_name,$exec_time,$priority" >> "$QUEUE_FILE"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Submitted - $student_id,$job_name,$exec_time,$priority" >> "$LOG_FILE"
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
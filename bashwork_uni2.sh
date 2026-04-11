#!/bin/bash

#part 2
TIME_QUANTUM=5

#part 3
LOG_FILE="scheduler_log.txt"
touch "$LOG_FILE"

#part 4
QUEUE_FILE="job_queue.txt"
COMPLETED_FILE="completed_jobs.txt"
touch "$QUEUE_FILE" "$COMPLETED_FILE"

submit_job() {
    read -p "Enter student ID: " student_id
    read -p "Enter job name: " job_name
    read -p "Enter execution time: " exec_time
    read -p "Enter job priority (1-10): " priority

    if [ "$priority" -lt 1 ] || [ "$priority" -gt 10 ]; then
        echo "Invalid priority."
        return
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') - $student_id - $job_name - Submitted" >> "$LOG_FILE"

    echo "$student_id,$job_name,$exec_time,$priority" >> "$QUEUE_FILE"
    echo "Job submitted."
}

view_pending_jobs() {
    echo "Pending jobs:"
    if [ -s "$QUEUE_FILE" ]; then
       cat "$QUEUE_FILE"
    else
       echo "No pending jobs."
    fi
}

process_round_robin() {
    if [ ! -s "$QUEUE_FILE" ]; then
        echo "No jobs in queue."
        return
    fi

    > temp_queue.txt

    while IFS=',' read -r student_id job_name exec_time priority
    do
        if [ "$exec_time" -gt "$TIME_QUANTUM" ]; then
            echo "$job_name processed for $TIME_QUANTUM seconds."
            echo "$(date '+%Y-%m-%d %H:%M:%S') - $student_id - $job_name - Round Robin" >> "$LOG_FILE"
            remaining=$((exec_time - TIME_QUANTUM))
            echo "$student_id,$job_name,$remaining,$priority" >> temp_queue.txt
        else
            echo "$job_name completed."

            echo "$(date '+%Y-%m-%d %H:%M:%S') - $student_id - $job_name - Round Robin" >> "$LOG_FILE"

            echo "$student_id,$job_name,$exec_time,$priority" >> "$COMPLETED_FILE"
        fi
    done < "$QUEUE_FILE"

    mv temp_queue.txt "$QUEUE_FILE"
}

process_priority() {
    if [ ! -s "$QUEUE_FILE" ]; then
        echo "No jobs in queue."
        return
    fi

    sort -t',' -k4,4nr "$QUEUE_FILE" > temp_queue.txt

    while IFS=',' read -r student_id job_name exec_time priority
    do
        echo "$job_name completed."

        echo "$(date '+%Y-%m-%d %H:%M:%S') - $student_id - $job_name - Priority" >> "$LOG_FILE"

        echo "$student_id,$job_name,$exec_time,$priority" >> "$COMPLETED_FILE"

    done < temp_queue.txt

    > "$QUEUE_FILE"

    rm temp_queue.txt
}

process_queue() {
    echo "1. Round Robin"
    echo "2. Priority"
    read -p "Choose scheduling method: " method

    case $method in
        1)
            process_round_robin
            ;;
        2)
            process_priority
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

view_completed_jobs() {
    echo "Completed jobs:"
    if [ -s "$COMPLETED_FILE" ]; then
        cat "$COMPLETED_FILE"
    else
        echo "No completed jobs."
    fi
}

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
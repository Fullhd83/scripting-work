#!/bin/bash

QUEUE_FILE="job_queue.txt"
COMPLETED_FILE="completed_jobs.txt"
LOG_FILE="scheduler_log.txt"
TIME_QUANTUM=5

touch "$QUEUE_FILE" "$COMPLETED_FILE" "$LOG_FILE"

log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

submit_job() {
    read -p "Enter student ID: " student_id
    read -p "Enter job name: " job_name
    read -p "Enter execution time: " exec_time
    read -p "Enter priority (1-10): " priority

    if ! [[ "$exec_time" =~ ^[0-9]+$ ]]; then
        echo "Execution time must be a number."
        return
    fi

    if ! [[ "$priority" =~ ^([1-9]|10)$ ]]; then
        echo "Priority must be between 1 and 10."
        return
    fi

    echo "$student_id,$job_name,$exec_time,$priority" >> "$QUEUE_FILE"
    log_event "Submitted - Student ID: $student_id, Job Name: $job_name, Scheduling Type: None"
    echo "Job submitted."
}

process_round_robin() {
    if [ ! -s "$QUEUE_FILE" ]; then
        echo "No jobs to process."
        return
    fi

    temp_file="temp_queue.txt"

    while [ -s "$QUEUE_FILE" ]; do
        > "$temp_file"

        while IFS=, read -r student_id job_name exec_time priority; do
            if [ "$exec_time" -gt "$TIME_QUANTUM" ]; then
                echo "$student_id,$job_name,$((exec_time - TIME_QUANTUM)),$priority" >> "$temp_file"
                log_event "Executed - Student ID: $student_id, Job Name: $job_name, Scheduling Type: Round Robin"
            else
                echo "$student_id,$job_name,$exec_time,$priority" >> "$COMPLETED_FILE"
                log_event "Executed - Student ID: $student_id, Job Name: $job_name, Scheduling Type: Round Robin"
            fi
        done < "$QUEUE_FILE"

        mv "$temp_file" "$QUEUE_FILE"
    done

    echo "Round Robin processing complete."
}

process_priority() {
    if [ ! -s "$QUEUE_FILE" ]; then
        echo "No jobs to process."
        return
    fi

    sort -t, -k4,4nr "$QUEUE_FILE" > temp_sorted.txt

    while IFS=, read -r student_id job_name exec_time priority; do
        echo "$student_id,$job_name,$exec_time,$priority" >> "$COMPLETED_FILE"
        log_event "Executed - Student ID: $student_id, Job Name: $job_name, Scheduling Type: Priority"
    done < temp_sorted.txt

    > "$QUEUE_FILE"
    rm -f temp_sorted.txt

    echo "Priority scheduling complete."
}

while true; do
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
            if [ ! -s "$QUEUE_FILE" ]; then
                echo "No pending jobs."
            else
                cat "$QUEUE_FILE"
            fi
            ;;
        2)
            submit_job
            ;;
        3)
            echo "1. Round Robin"
            echo "2. Priority Scheduling"
            read -p "Choose scheduling method: " method

            if [ "$method" = "1" ]; then
                process_round_robin
            elif [ "$method" = "2" ]; then
                process_priority
            else
                echo "Invalid method."
            fi
            ;;
        4)
            if [ ! -s "$COMPLETED_FILE" ]; then
                echo "No completed jobs."
            else
                cat "$COMPLETED_FILE"
            fi
            ;;
        5)
            read -p "Are you sure you want to exit? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                echo "Goodbye!"
                break
            fi
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
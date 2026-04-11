#!/bin/bash

# Part 4: Data Storage
# This file stores all jobs that are still waiting to be processed.
QUEUE_FILE="job_queue.txt"

# This file stores all jobs that have finished processing.
COMPLETED_FILE="completed_jobs.txt"

# Create the two files if they do not already exist.
# This avoids errors later when the script tries to write to them.
touch "$QUEUE_FILE" "$COMPLETED_FILE"


# Part 3: Logging System
# This file stores the log of job submissions and job execution events.
LOG_FILE="scheduler_log.txt"

# Create the log file if it does not already exist.
touch "$LOG_FILE"


# Part 2: Queue Based Scheduling System
# Round Robin must use a time quantum of 5 seconds.
TIME_QUANTUM=5

submit_job() {
    read -p "Enter student ID: " student_id
    read -p "Enter job name: " job_name
    read -p "Enter execution time: " exec_time
    read -p "Enter job priority (1-10): " priority

    # Check that the priority is between 1 and 10.
    if [ "$priority" -lt 1 ] || [ "$priority" -gt 10 ]; then
        echo "Invalid priority."
        return
    fi

    # Part 4: Data Storage
    # Save the submitted job into the pending jobs file.
    # Format: studentID,jobName,executionTime,priority
    echo "$student_id,$job_name,$exec_time,$priority" >> "$QUEUE_FILE"

    echo "Job submitted."

    # Part 3: Logging System
    # Log the submission event with timestamp, student ID and job name.
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $student_id - $job_name - Submitted" >> "$LOG_FILE"
}

view_pending_jobs() {
    echo "Pending jobs:"

    # Part 4: Data Storage
    # If the pending jobs file has content, show it.
    # Otherwise tell the user there are no pending jobs.
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

    # Temporary file used to store jobs that are not finished yet.
    # After one round of processing, this file becomes the new queue.
    > temp_queue.txt

    while IFS=',' read -r student_id job_name exec_time priority
    do
        # If execution time is more than 5 seconds,
        # process it for 5 seconds and keep the remaining time in the queue.
        if [ "$exec_time" -gt 5 ]; then
            echo "$job_name processed for 5 seconds."

            # Part 3: Logging System
            # Log that this job was processed using Round Robin.
            echo "$(date '+%Y-%m-%d %H:%M:%S') - $student_id - $job_name - Round Robin" >> "$LOG_FILE"

            # Reduce the remaining execution time by 5 seconds.
            remaining=$((exec_time - 5))

            # Part 4: Data Storage
            # Save the unfinished job back into the temporary queue file.
            echo "$student_id,$job_name,$remaining,$priority" >> temp_queue.txt

        else
            # If execution time is 5 or less, the job finishes now.
            echo "$job_name completed."

            # Part 4: Data Storage
            # Move the completed job into the completed jobs file.
            echo "$student_id,$job_name,$exec_time,$priority" >> "$COMPLETED_FILE"

            # Part 3: Logging System
            # Log that this job was executed using Round Robin.
            echo "$(date '+%Y-%m-%d %H:%M:%S') - $student_id - $job_name - Round Robin" >> "$LOG_FILE"
        fi
    done < "$QUEUE_FILE"

    # Part 4: Data Storage
    # Replace the old queue file with the updated queue.
    mv temp_queue.txt "$QUEUE_FILE"
}

process_priority() {
    if [ ! -s "$QUEUE_FILE" ]; then
        echo "No jobs in queue."
        return
    fi

    # Sort jobs by priority in descending order.
    # Highest priority is processed first.
    sort -t',' -k4,4nr "$QUEUE_FILE" > temp_queue.txt

    while IFS=',' read -r student_id job_name exec_time priority
    do
        echo "$job_name completed."

        # Part 4: Data Storage
        # Store the completed job in the completed jobs file.
        echo "$student_id,$job_name,$exec_time,$priority" >> "$COMPLETED_FILE"

        # Part 3: Logging System
        # Log that this job was executed using Priority scheduling.
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $student_id - $job_name - Priority" >> "$LOG_FILE"
    done < temp_queue.txt

    # Part 4: Data Storage
    # After all jobs are completed, clear the pending queue file.
    > "$QUEUE_FILE"

    # Remove the temporary sorted file because it is no longer needed.
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

    # Part 4: Data Storage
    # Show completed jobs if the file is not empty.
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
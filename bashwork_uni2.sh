#!/bin/bash

#part 2
queue=()
completed_jobs=()
TIME_QUANTUM=5

submit_job() {
    read -p "Enter student ID: " student_id
    read -p "Enter job name: " job_name
    read -p "Enter execution time: " exec_time
    read -p "Enter job priority (1-10): " priority

    if [ "$priority" -lt 1 ] || [ "$priority" -gt 10 ]; then
        echo "Invalid priority."
        return
    fi

    queue+=("$student_id,$job_name,$exec_time,$priority")
    echo "Job submitted."
}

view_pending_jobs() {
    echo "Pending jobs:"
    if [ ${#queue[@]} -eq 0 ]; then
        echo "No pending jobs."
    else
        for job in "${queue[@]}"
        do
            echo "$job"
        done
    fi
}

process_round_robin() {
    if [ ${#queue[@]} -eq 0 ]; then
        echo "No jobs in queue."
        return
    fi

    new_queue=()

    for job in "${queue[@]}"
    do
        IFS=',' read -r student_id job_name exec_time priority <<< "$job"

        if [ "$exec_time" -gt "$TIME_QUANTUM" ]; then
            echo "$job_name processed for $TIME_QUANTUM seconds."
            remaining=$((exec_time - TIME_QUANTUM))
            new_queue+=("$student_id,$job_name,$remaining,$priority")
        else
            echo "$job_name completed."
            completed_jobs+=("$student_id,$job_name,$exec_time,$priority")
        fi
    done

    queue=("${new_queue[@]}")
}

process_priority() {
    if [ ${#queue[@]} -eq 0 ]; then
        echo "No jobs in queue."
        return
    fi

    sorted_jobs=$(printf "%s\n" "${queue[@]}" | sort -t',' -k4,4nr)

    while IFS= read -r job
    do
        IFS=',' read -r student_id job_name exec_time priority <<< "$job"
        echo "$job_name completed."
        completed_jobs+=("$student_id,$job_name,$exec_time,$priority")
    done <<< "$sorted_jobs"

    queue=()
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
    if [ ${#completed_jobs[@]} -eq 0 ]; then
        echo "No completed jobs."
    else
        for job in "${completed_jobs[@]}"
        do
            echo "$job"
        done
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
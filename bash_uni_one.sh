
#!/bin/bash

LOG_FILE="system_monitor_log.txt"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Script started" >> $LOG_FILE
#part 1.1
echo ""
echo "CPU Information:"
top -bn1 | grep "Cpu(s)"

echo ""
echo "Memory Information:"
free -h
echo ""

#part 1.2
echo "top 10 memory consuming processes:"
echo ""
echo "PID USER CPU% MEM%"
ps -eo pid,user,%cpu,%mem --sort=-%mem | head -n 11

#part 1.3
read -p "Enter the PID of the process to kill: " pid

if [ -z "$pid" ]; then
    echo "No PID entered. Exiting."

else #part 1.4 check to see if the process is critical
    if [ "$pid" -eq 1 ] || [ "$pid" -eq $$ ]; then
        echo "Cannot kill this critical process."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Attempted to kill critical process $pid" >> $LOG_FILE
    else 
        if ps -p "$pid" > /dev/null; then
            read -p "Are you sure you want to kill process $pid? (y/n): " confirm

            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                kill "$pid"

                if [ $? -eq 0 ]; then
                    echo "Process $pid has been killed."
                    echo "$(date '+%Y-%m-%d %H:%M:%S') - Killed PID $pid" >> $LOG_FILE
                else
                    echo "Failed to kill process $pid (permission denied)."
                    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to kill PID $pid" >> $LOG_FILE
                fi
            else
                echo "Process $pid was not killed."
            fi
        else
            echo "No process with PID $pid found. Exiting."
        fi
    fi
fi

echo ""
#part 2.1

read -p "Enter directory to inspect: " dir

if [ ! -d "$dir" ]; then
    echo "Directory does not exist."

else
    echo ""
du -sh "$dir"

#part 2.2
echo ""
mkdir -p ArchiveLogs

#part 2.3 & 2.4
find "$dir" -type f -name "*.log" -size +50M | while read file 
do
    timestamp=$(date +%Y%m%d%H%M%S)
    gzip -c "$file" > "ArchiveLogs/$(basename "$file")_$timestamp.gz"
    echo "Archived: $file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Archived $file" >> $LOG_FILE
done

#part 2.5
echo ""
size=$(du -sm ArchiveLogs | cut -f1)
    if [ "$size" -gt 1024 ]; then
        echo "Total size of archived logs exceeds 1GB."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ArchiveLogs size: ${size}MB" >> $LOG_FILE
    else
        echo "Total size of archived logs is within the limit."
    fi
fi

read -p "Do you want to exit? (y/n): " choice

if [ "$choice" = "y" ]; then
    echo "Goodbye!"
    exit 0
else
    echo "Continuing..."
fi
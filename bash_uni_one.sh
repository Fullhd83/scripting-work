
#!/bin/bash
echo "part 1.1"
echo ""
echo "CPU Information:"
top -bn1 | grep "Cpu(s)"

echo ""
echo "Memory Information:"
free -h
echo ""

echo "part 1.2"
echo "top 10 memory consuming processes:"
echo ""
echo "PID USER CPU% MEM%"
ps -eo pid,user,%cpu,%mem --sort=-%mem | head -n 11

echo "part 1.3" 
read -p "Enter the PID of the process to kill: " pid

if [ -z "$pid" ]; then
    echo "No PID entered. Exiting."

else
    if [ "$pid" -eq 1 ] || [ "$pid" -eq $$ ]; then
        echo "Cannot kill this critical process. Exiting."
    else 
        if ps -p "$pid" > /dev/null; then
            read -p "Are you sure you want to kill process $pid? (y/n): " confirm

            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                kill "$pid"

                if [ $? -eq 0 ]; then
                    echo "Process $pid has been killed."
                else
                    echo "Failed to kill process $pid (permission denied)."
                fi
            else
                echo "Process $pid was not killed."
            fi
        else
            echo "No process with PID $pid found. Exiting."
        fi
    fi
fi
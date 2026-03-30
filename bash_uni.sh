
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
printf "%-8s %-15s %-8s %-8s\n" "PID" "USER" "CPU%" "MEM%"
echo ""
ps -eo pid,user,%cpu,%mem --sort=-%mem | head -n 11 
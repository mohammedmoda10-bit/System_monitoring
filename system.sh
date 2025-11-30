#!/bin/bash


THRESHOLD=80
OUTPUT_FILE="system_monitor.log"

# Function to get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Parse command line arguments
while getopts "t:f:h" opt; do
    case $opt in
        t) THRESHOLD=$OPTARG ;;
        f) OUTPUT_FILE=$OPTARG ;;
        h) 
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -t THRESHOLD    Set disk usage warning threshold (default: 80)"
            echo "  -f FILENAME     Set output file name (default: system_monitor.log)"
            exit 0
            ;;
    esac
done

# Main script
echo "System Monitoring Report - $(get_timestamp)"
echo "============================="
echo ""

# Disk Usage
echo "Disk Usage:"
df -h | grep -E '^/dev/sd' | while read -r line; do
    device=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    used=$(echo "$line" | awk '{print $3}')
    avail=$(echo "$line" | awk '{print $4}')
    use_percent=$(echo "$line" | awk '{print $5}')
    mount=$(echo "$line" | awk '{print $6}')
    
    echo "Filesystem $device"
    echo "Size Used Avail Use% Mounted on"
    echo "$size $used $avail $use_percent $mount"
    
    # Remove % and check threshold
    percent_num=$(echo "$use_percent" | tr -d '%')
    if [ "$percent_num" -gt "$THRESHOLD" ]; then
        echo "Warning: $device is above $THRESHOLD% usage!"
    fi
    echo ""
done

# CPU Usage
echo "CPU Usage:"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f%%", $2 + $4}')
echo "Current CPU Usage: $cpu_usage"
echo ""

# Memory Usage
echo "Memory Usage:"
free -h | grep 'Mem:' | awk '{print "Total Memory: " $2 "\nUsed Memory: " $3 "\nFree Memory: " $4}'
echo ""

# Top Processes
echo "Top 5 Memory-Consuming Processes:"
echo "PID USER %MEM COMMAND"
ps aux --sort=-%mem | awk 'NR>1 && NR<=6 {printf "%-6s %-8s %-5s %s\n", $2, $1, $4, $11}'

# Save to log file
{
    echo "System Monitoring Report - $(get_timestamp)"
    echo "============================="
    echo ""
    echo "Disk Usage:"
    df -h | grep -E '^/dev/sd' | while read -r line; do
        device=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        used=$(echo "$line" | awk '{print $3}')
        avail=$(echo "$line" | awk '{print $4}')
        use_percent=$(echo "$line" | awk '{print $5}')
        mount=$(echo "$line" | awk '{print $6}')
        
        echo "Filesystem $device"
        echo "Size Used Avail Use% Mounted on"
        echo "$size $used $avail $use_percent $mount"
        
        percent_num=$(echo "$use_percent" | tr -d '%')
        if [ "$percent_num" -gt "$THRESHOLD" ]; then
            echo "Warning: $device is above $THRESHOLD% usage!"
        fi
        echo ""
    done
    
    echo "CPU Usage:"
    echo "Current CPU Usage: $cpu_usage"
    echo ""
    
    echo "Memory Usage:"
    free -h | grep 'Mem:' | awk '{print "Total Memory: " $2 "\nUsed Memory: " $3 "\nFree Memory: " $4}'
    echo ""
    
    echo "Top 5 Memory-Consuming Processes:"
    echo "PID USER %MEM COMMAND"
    ps aux --sort=-%mem | awk 'NR>1 && NR<=6 {printf "%-6s %-8s %-5s %s\n", $2, $1, $4, $11}'
    
} > "$OUTPUT_FILE"

echo ""
echo "Report saved to: $OUTPUT_FILE"

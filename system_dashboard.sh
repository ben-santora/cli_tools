#!/bin/bash
# system_dashboard.sh - A YAD-based System Health Dashboard
# Fixed version - no --key parsing errors

# Configuration
TITLE="System Dashboard"
WIDTH=730
HEIGHT=360
UPDATE_INTERVAL=5  # seconds
LOG_FILE="$HOME/.sysdash.log"

# Get system health info
get_health_info() {
    # CPU usage - optimized using top -n1 with a short delay
    CPU=$(top -bn1 -d 0.1 | grep "Cpu(s)" | tail -1 | awk '{print $2}' | cut -d'%' -f1)
    
    # Memory usage
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    MEM_PERC=$((MEM_USED * 100 / MEM_TOTAL 2>/dev/null || echo 0))
    
    # Disk usage (root partition)
    DISK_PERC=$(df / --output=pcent 2>/dev/null | tail -1 | tr -d '% ' || echo 0)
    
    # Uptime
    UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "Unknown")
    
    # Load average
    LOAD=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | xargs || echo "Unknown")
    
    # Status indicator
    STATUS="Healthy"
    [ "${CPU%.*}" -gt 80 ] 2>/dev/null || [ $MEM_PERC -gt 85 ] || [ $DISK_PERC -gt 90 ] && STATUS="High Usage"

    # Create the health display - adjusted for wider window
    echo "--text=\"<b>System Health Monitor</b> | Status: <b>$STATUS</b>
<span font='monospace'>
<b>CPU:</b>  ${CPU}%    <b>Mem:</b>  ${MEM_PERC}% (${MEM_USED}M/${MEM_TOTAL}M)   <b>Disk:</b> ${DISK_PERC}%
<b>Up:</b>   ${UPTIME}  <b>Load:</b> ${LOAD}</span>\""
}

# Action functions
clear_cache() {
    yad --question --title="Confirm Action" --text="Are you sure you want to clear the package cache? Existing packages will be removed from your local storage." --button="Cancel:1" --button="Clear Cache:0" --width=350 --center
    if [ $? -ne 0 ]; then return; fi

    echo "Clearing package cache..." > "$LOG_FILE"
    if command -v apt &>/dev/null; then
        sudo apt clean 2>&1 >> "$LOG_FILE"
        MSG="APT cache cleared"
    elif command -v dnf &>/dev/null; then
        sudo dnf clean all 2>&1 >> "$LOG_FILE"
        MSG="DNF cache cleared"
    elif command -v yum &>/dev/null; then
        sudo yum clean all 2>&1 >> "$LOG_FILE"
        MSG="YUM cache cleared"
    else
        MSG="No supported package manager found"
    fi
    yad --info --title="Cache Cleared" --text="$MSG" --width=300 --button="OK" --center
}

check_updates() {
    echo "Checking for updates..." > "$LOG_FILE"
    if command -v apt &>/dev/null; then
        UPDATES=$(apt list --upgradable 2>/dev/null | wc -l)
        UPDATES=$((UPDATES-1))
        if [ $UPDATES -gt 0 ]; then
            MSG="$UPDATES packages have available updates.\n\nRun: sudo apt upgrade"
        else
            MSG="System is up to date!"
        fi
    elif command -v dnf &>/dev/null; then
        sudo dnf check-update > /tmp/updates.txt 2>&1
        if grep -q "available" /tmp/updates.txt; then
            MSG="Updates available. Check terminal for details."
        else
            MSG="System is up to date!"
        fi
    else
        MSG="Update check not supported for this package manager"
    fi
    yad --info --title="Updates" --text="$MSG" --width=350 --button="OK" --center
}

restart_service() {
    SERVICE_CHOICE=$(yad --list --title="Restart Service" --width=400 --height=300 \
        --column="Safe Services" \
        "NetworkManager" "bluetooth" "docker" "cups" "ssh" "nginx" "apache2" "postgresql" "mysql" "Other..." \
        --button="Cancel:1" --button="Next:0" --center)
    
    if [ $? -ne 0 ] || [ -z "$SERVICE_CHOICE" ]; then return; fi
    
    SERVICE=$(echo "$SERVICE_CHOICE" | cut -d'|' -f1)
    
    if [ "$SERVICE" = "Other..." ]; then
        SERVICE=$(yad --entry --title="Custom Service" --text="<b>WARNING:</b> Restarting critical system services can cause system instability or lock you out.\n\nEnter service name:" \
            --width=400 --button="Cancel:1" --button="Restart:0" --center)
        if [ $? -ne 0 ] || [ -z "$SERVICE" ]; then return; fi
    fi

    yad --question --title="Confirm Restart" --text="Are you sure you want to restart <b>$SERVICE</b>?" --button="Cancel:1" --button="Restart:0" --width=350 --center
    if [ $? -eq 0 ]; then
        sudo systemctl restart "$SERVICE" 2>&1 | \
            yad --text-info --title="Service Restart Result" --width=400 --height=200 \
            --button="OK" --center
    fi
}

view_logs() {
    LOG=$(yad --list --title="Select Log File" --width=350 --height=250 \
        --column="Log File" \
        "/var/log/syslog" \
        "/var/log/auth.log" \
        "/var/log/kern.log" \
        "/var/log/dpkg.log" \
        "Custom Log..." \
        --button="Cancel:1" --button="View:0" --center)
    
    if [ $? -eq 0 ] && [ -n "$LOG" ]; then
        LOG_PATH=$(echo "$LOG" | cut -d'|' -f1)
        if [ "$LOG_PATH" = "Custom Log..." ]; then
            LOG_PATH=$(yad --file --title="Select Log File" --width=600 --height=400 --center)
        fi
        if [ -n "$LOG_PATH" ]; then
            if [ -f "$LOG_PATH" ] && [ -r "$LOG_PATH" ]; then
                tail -20 "$LOG_PATH" | \
                    yad --text-info --title="Log: $(basename "$LOG_PATH")" \
                    --width=700 --height=400 --button="OK" --center
            else
                yad --error --title="Log Error" --text="Cannot read log file: $LOG_PATH\n\nEnsure the file exists and you have permission." --width=400 --center
            fi
        fi
    fi
}

disk_check() {
    df -h | yad --text-info --title="Disk Usage" \
        --width=700 --height=300 --button="OK" --center
}

# Main menu loop
while true; do
    ACTION=$(yad --title="$TITLE" --width=$WIDTH --height=$HEIGHT \
        $(get_health_info) \
        --form \
        --field="Quick Actions:CB" "Clear Cache!Check Updates!Restart Service!View Logs!Disk Check!Refresh" \
        --button="Quit:1" --button="Execute:0" \
        --center)
    
    # Check if user quit
    RETVAL=$?
    if [ $RETVAL -eq 1 ] || [ $RETVAL -eq 252 ]; then
        exit 0
    fi
    
    # Get selected action
    SELECTED_ACTION=$(echo "$ACTION" | cut -d'|' -f1)
    
    # Execute action
    case "$SELECTED_ACTION" in
        "Clear Cache") clear_cache ;;
        "Check Updates") check_updates ;;
        "Restart Service") restart_service ;;
        "View Logs") view_logs ;;
        "Disk Check") disk_check ;;
        "Refresh") ;;  # Just continue to refresh immediately
    esac
done

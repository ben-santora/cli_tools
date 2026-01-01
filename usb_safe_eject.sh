#!/bin/bash

# USB Safe Eject Monitor - Fixed Version
# Usage: ./usb_safe_eject_fixed.sh <device> (e.g., sdb, sdc1)

dev="${1#/dev/}"
if [[ -z "$dev" ]] || ! [[ -e "/dev/$dev" ]]; then
    echo "Usage: $0 <block_device> (e.g., sdb, sdc1)" >&2
    exit 1
fi

full_dev="/dev/$dev"

# Configuration
INACTIVE_SECONDS=5  # Wait 5 seconds of inactivity before safe
QUIET_PERIOD=1      # Check every second

# Function to get I/O stats
get_io_stats() {
    awk "\$3==\"$dev\" {print \$6, \$10}" /proc/diskstats
}

# Function to check for pending I/O
check_pending_io() {
    local ios=$(awk "\$3==\"$dev\" {print \$10}" /proc/diskstats 2>/dev/null)
    echo "${ios:-0}"
}

echo "=== USB Safe Eject Monitor ==="
echo "Device: $full_dev"
echo "Will wait $INACTIVE_SECONDS seconds of inactivity before declaring safe"

# Check if device exists
if ! get_io_stats >/dev/null 2>&1; then
    echo "Error: Device $dev not found" >&2
    exit 1
fi

# Sync if mounted
mounted_points=$(mount | grep "$full_dev" || true)
if [[ -n "$mounted_points" ]]; then
    echo "Device is mounted, running sync..."
    sync "$full_dev" 2>/dev/null || sync
fi

# Get initial stats
initial_stats=$(get_io_stats)
read rsect wsect _ <<< "$initial_stats"
prev_total=$((rsect + wsect))
prev_pending=$(check_pending_io)

echo "Monitoring I/O activity... Press Ctrl+C to exit"
echo "---"

consecutive_inactive=0
last_activity_time=$(date +%s)

# Monitoring loop
while true; do
    sleep $QUIET_PERIOD
    
    current_stats=$(get_io_stats)
    if [[ -z "$current_stats" ]]; then
        echo "Error: Device $dev no longer found"
        exit 1
    fi
    
    read nrsect nwsect _ <<< "$current_stats"
    total=$((nrsect + nwsect))
    current_pending=$(check_pending_io)
    
    # Calculate deltas
    delta=$((total - prev_total))
    pending_delta=$((current_pending - prev_pending))
    
    # Check for activity
    if [[ $delta -gt 0 || $pending_delta -ne 0 ]]; then
        # Activity detected
        consecutive_inactive=0
        last_activity_time=$(date +%s)
        
        if [[ $delta -gt 0 ]]; then
            rate_kb=$((delta * 512 / 1024))
            echo "🔄 Active: ${rate_kb} KiB/s transferred"
        fi
        
        if [[ $current_pending -gt 0 ]]; then
            echo "⏳ Pending: $current_pending I/O operations"
        fi
    else
        # No activity
        consecutive_inactive=$((consecutive_inactive + 1))
        seconds_since_activity=$(($(date +%s) - last_activity_time))
        
        if [[ $consecutive_inactive -ge $INACTIVE_SECONDS ]]; then
            echo ""
            echo "🟢 SAFE TO EJECT - No activity for $INACTIVE_SECONDS seconds"
            echo "   Total I/O: $((total * 512 / 1024 / 1024)) MiB"
            echo "   Status: Ready for safe removal"
            echo ""
            echo "To eject safely:"
            [[ -n "$mounted_points" ]] && echo "  sudo umount $full_dev"
            echo "  sudo eject $full_dev"
            break
        else
            echo "⏳ Quiet for ${seconds_since_activity}s (${consecutive_inactive}/${INACTIVE_SECONDS})"
        fi
    fi
    
    prev_total=$total
    prev_pending=$current_pending
done

# USB Safe-Eject Monitor

A small Bash utility that waits until a USB mass-storage device is **really** idle before telling you it is safe to unplug or spin-down.  
It watches both data-transfer counters and the kernel’s pending-I/O queue, so it won’t give the “all-clear” while buffers are still flushing or a big `rsync` is only paused for a second.

---

## What it does

1. Checks that the device exists in `/proc/diskstats`.
2. If the device (or any of its partitions) is mounted, runs `sync` on it.
3. Polls `/proc/diskstats` every second:
   - Sectors read/written – detects active data flow.  
   - “I/Os currently in flight” – detects queued requests.  
4. Waits until **both** counters stay at zero for a configurable number of seconds (default 5).  
5. Prints the exact `umount` / `eject` commands you still need to type.

---

## Download & make executable

```bash
wget https://raw.githubusercontent.com/YOU/usb-safe-eject/main/usb_safe_eject.sh
chmod +x usb_safe_eject.sh
```


## Usage

./usb_safe_eject.sh <device> - can be the full path (/dev/sdb) or just the short name (sdb, sdc1, …).

## Typical session:

$ ./usb_safe_eject.sh sdc

=== USB Safe Eject Monitor ===
Device: /dev/sdc
Will wait for 5 seconds of inactivity before declaring safe
Device is mounted, running sync...
✓ Sync completed
---
🔄 Active: 17  MiB/s transferred
⏳ Pending: 126 I/O operations
🔄 Active: 21  MiB/s transferred
⏳ Pending: 0   I/O operations
⏳ Quiet for 3s (3/5)
⏳ Quiet for 4s (4/5)
🟢 SAFE TO EJECT - No activity for 5 seconds
   Total I/O: 3.9 GiB
   Status: Ready for safe removal

To eject safely:
  sudo umount /dev/sdc1
  sudo eject /dev/sdc1

Press Ctrl-C at any time to abort without touching the device.

## Configuration

Edit the variables at the top of the script:

Variable	Meaning	Default
INACTIVE_SECONDS	How many consecutive quiet seconds are required	5
QUIET_PERIOD	Sleep between polls (seconds)	1
Code	Reason
0	Device became idle and is safe to remove
1	Device not found, already removed, or usage error

## Requirements

    Linux kernel (any recent version that exports /proc/diskstats)
    Bash ≥ 4
    Standard POSIX utilities: awk, grep, mount, sync, date

No root privileges are needed until you actually run the final umount/eject commands printed by the script.
Why not just sync && umount?
sync only flushes file-system buffers; the block layer may still have queued requests, and many copy tools (e.g. pv, dd, cat) pause between bursts.
This script waits until the disk layer is also idle, avoiding the “write failed” dialog or file-system check on next plug-in.

## License
MIT – free to use and modify

## Creator
Ben Santora

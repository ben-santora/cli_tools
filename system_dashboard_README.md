# System Dashboard

A lightweight, YAD-based GUI for monitoring system health and performing common maintenance tasks.

## Features
- **Real-time Monitoring**: CPU, Memory, Disk, and Load stats.
- **Quick Actions**: Clear package cache, check for updates, and view system logs.
- **Safe Service Control**: Restart common services (Docker, NetworkManager, etc.) with built-in safety confirmations.
- **Persistence**: The dashboard stays open and centered after tasks are completed.

## Requirements
- `yad` (the UI engine)
- `sudo` privileges for maintenance actions

## Usage
1. Ensure the script is executable:
   ```bash
   chmod +x system_dashboard.sh
   ```
2. Launch it:
   ```bash
   ./system_dashboard.sh
   ```

## Logs
Action results are saved to `~/.sysdash.log` for future reference. (This is a hidden file in your home directory).

# Clears the contents of a Ventoy USB

#!/usr/bin/env bash
MNT=$(lsblk -o LABEL,MOUNTPOINT -nr | awk '$1=="Ventoy"{print $2}')
[[ -z "$MNT" ]] && exit 1

find "$MNT" -mindepth 1 -maxdepth 1 \
  ! -name ventoy ! -name EFI -exec rm -rf {} +

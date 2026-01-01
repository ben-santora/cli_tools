# Checks a Ventoy USB - returns contents or empty

#!/usr/bin/env bash
# ventoy-check.sh
MNT=$(lsblk -o LABEL,MOUNTPOINT -nr | awk '$1=="Ventoy"{print $2}')

[[ -z "$MNT" ]] && { echo "Ventoy not mounted"; exit 1; }

mapfile -t files < <(find "$MNT" -maxdepth 1 -type f)

if (( ${#files[@]} == 0 )); then
  echo "USB empty"
else
  printf "%s\n" "${files[@]##*/}"
fi

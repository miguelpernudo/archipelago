#!/bin/sh
# shellcheck disable=SC2154  # inherited via set -a from config.sh

CURRENT_DISK=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$CURRENT_DISK" -gt "$DISK_CRITICAL" ]; then
    exit 2
elif [ "$CURRENT_DISK" -gt "$DISK_LIMIT" ]; then
    exit 1
else
    exit 0
fi

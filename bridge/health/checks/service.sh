#!/bin/sh

failed=0
for svc in hostapd; do
    if ! rc-service "$svc" status > /dev/null 2>&1; then
        failed=$((failed + 1))
    fi
done

if [ "$failed" -ge 2 ]; then
    exit 2
elif [ "$failed" -eq 1 ]; then
    exit 1
else
    exit 0
fi

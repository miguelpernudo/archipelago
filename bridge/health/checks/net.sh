#!/bin/sh
# shellcheck disable=SC2154  # inherited via set -a from config.sh

if ping -c 1 "$NET_TARGET" > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi

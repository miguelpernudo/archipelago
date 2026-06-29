#!/bin/sh

# shellcheck disable=SC2034

DISK_LIMIT=90
DISK_CRITICAL=97

NET_TARGET="8.8.8.8"

FAILURE_LIMIT=3

STATE_DIR="/var/lib/pathfinder"
LOG="/var/log/pathfinder.log"

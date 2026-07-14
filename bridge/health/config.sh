#!/bin/sh

# shellcheck disable=SC2034  # consumed by health.sh checks and handlers

DISK_LIMIT=90
DISK_CRITICAL=97

NET_TARGET="8.8.8.8"

FAILURE_LIMIT=3

STATE_DIR="/var/lib/krill"
LOG="/var/log/krill.log"

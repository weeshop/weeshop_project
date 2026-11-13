#!/bin/bash
# Retry a command until it succeeds.
# Usage: try_command "<command>" [timeout_seconds]
# shellcheck disable=SC2329

try_command() {
  local cmd="$1"
  local timeout_secs="${2:-10}"
  local status

  while true; do
    # Capture $? before any other builtin (e.g. local) overwrites it.
    timeout -k $((timeout_secs + 10)) "$timeout_secs" bash -c "$cmd"
    status=$?
    if [[ $status -eq 0 ]]; then
      return 0
    fi
    if [[ $status -eq 124 ]]; then
      echo "Timeout after ${timeout_secs}s, retry ..."
    else
      echo "Command failed (exit ${status}), retry ..."
    fi
    sleep 1
  done
}

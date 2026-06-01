#!/bin/bash
set -euo pipefail

required_vars=(
  RESTIC_REPOSITORY
  RESTIC_PASSWORD
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_DEFAULT_REGION
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required variable: ${var_name}" >&2
    exit 1
  fi
done

if ! restic snapshots >/dev/null 2>&1; then
  restic init
fi

restic backup /data

if [[ -z "${RESTIC_FORGET_ARGS:-}" ]]; then
  echo "Missing required variable: RESTIC_FORGET_ARGS" >&2
  exit 1
fi

read -r -a forget_args <<< "${RESTIC_FORGET_ARGS}"
restic forget "${forget_args[@]}"

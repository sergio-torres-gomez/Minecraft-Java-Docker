#!/bin/bash
set -euo pipefail

required_vars=(
  RESTIC_REPOSITORY
  RESTIC_PASSWORD
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_DEFAULT_REGION
  RESTIC_FORGET_ARGS
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required variable: ${var_name}" >&2
    exit 1
  fi
done

if ! restic snapshots >/dev/null 2>&1; then
  echo "Restic repository not found, initializing..."
  restic init
fi

restic backup /data

read -r -a forget_args <<< "${RESTIC_FORGET_ARGS}"
restic forget "${forget_args[@]}"

has_prune="false"
for arg in "${forget_args[@]}"; do
  if [[ "${arg}" == "--prune" ]]; then
    has_prune="true"
    break
  fi
done

if [[ "${has_prune}" == "false" ]]; then
  restic prune
fi

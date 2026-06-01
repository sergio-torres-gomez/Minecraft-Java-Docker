#!/bin/bash
set -euo pipefail

# These values are mandatory and must be provided
if [[ -z "${RESTIC_CRON_SCHEDULE:-}" ]]; then
  echo "ERROR: RESTIC_CRON_SCHEDULE is not set. This is a mandatory configuration." >&2
  exit 1
fi

if [[ -z "${TZ:-}" ]]; then
  echo "ERROR: TZ is not set. This is a mandatory configuration." >&2
  exit 1
fi

if [[ -z "${RESTIC_CRON_LOG_PATH:-}" ]]; then
  echo "ERROR: RESTIC_CRON_LOG_PATH is not set. This is a mandatory configuration." >&2
  exit 1
fi

if [[ ! "${RESTIC_CRON_LOG_PATH}" =~ ^/[A-Za-z0-9._/-]+$ || "${RESTIC_CRON_LOG_PATH}" == *".."* ]]; then
  echo "ERROR: Invalid RESTIC_CRON_LOG_PATH '${RESTIC_CRON_LOG_PATH}'. Must be an absolute path." >&2
  exit 1
fi

if [[ "${RESTIC_CRON_LOG_PATH}" != "/proc/1/fd/1" ]]; then
  log_dir="$(dirname "${RESTIC_CRON_LOG_PATH}")"
  mkdir -p "${log_dir}"
  touch "${RESTIC_CRON_LOG_PATH}"
fi

if [[ ! -f "/usr/share/zoneinfo/${TZ}" ]]; then
  echo "ERROR: Invalid TZ '${TZ}'. Must be a valid timezone in /usr/share/zoneinfo/." >&2
  exit 1
fi

ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
echo "${TZ}" > /etc/timezone

echo "${RESTIC_CRON_SCHEDULE} /usr/local/bin/run-backup.sh >> ${RESTIC_CRON_LOG_PATH} 2>&1" > /etc/crontabs/root

if [[ "${RESTIC_RUN_ON_STARTUP:-false}" == "true" ]]; then
  /usr/local/bin/run-backup.sh
fi

exec crond -f -l 8

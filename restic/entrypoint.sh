#!/bin/bash
set -euo pipefail

: "${RESTIC_CRON_SCHEDULE:=0 5 * * *}"
: "${TZ:=UTC}"
: "${RESTIC_CRON_LOG_PATH:=/proc/1/fd/1}"

if [[ -f "/usr/share/zoneinfo/${TZ}" ]]; then
  ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
  echo "${TZ}" > /etc/timezone
else
  echo "Invalid TZ '${TZ}', using UTC"
  TZ="UTC"
  ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
  echo "${TZ}" > /etc/timezone
fi

echo "${RESTIC_CRON_SCHEDULE} /usr/local/bin/run-backup.sh >> ${RESTIC_CRON_LOG_PATH} 2>&1" > /etc/crontabs/root

if [[ "${RESTIC_RUN_ON_STARTUP:-false}" == "true" ]]; then
  /usr/local/bin/run-backup.sh
fi

exec crond -f -l 8

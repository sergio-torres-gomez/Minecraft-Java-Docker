#!/bin/bash
set -euo pipefail

: "${RESTIC_CRON_SCHEDULE:=0 5 * * *}"
: "${TZ:=UTC}"

if [[ -f "/usr/share/zoneinfo/${TZ}" ]]; then
  ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
  echo "${TZ}" > /etc/timezone
fi

echo "${RESTIC_CRON_SCHEDULE} /usr/local/bin/run-backup.sh >> /var/log/restic-cron.log 2>&1" > /etc/crontabs/root

if [[ "${RESTIC_RUN_ON_STARTUP:-false}" == "true" ]]; then
  /usr/local/bin/run-backup.sh
fi

exec crond -f -l 8

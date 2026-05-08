#!/bin/bash

# Exit script if command fails
set -e

# Display Help
Help() {
  echo
  echo "minecraft-bind-backup"
  echo "####################"
  echo
  echo "Description: Backup bind mount data directory."
  echo "Syntax: minecraft-bind-backup [-p|-o|-c|help]"
  echo "Example: minecraft-bind-backup -p /var/www/minecraft/.data -o /tmp -c Minecraft"
  echo "options:"
  echo "  -p    Data directory path to backup."
  echo "  -o    Output directory. Defaults to '/var/tmp'"
  echo "  -c    Logical name for backup subfolder."
  echo "  -r    Clear directory? true/false(default)"
  echo "  -d    Delete files older than this many days (set 0 to keep all)"
  echo "  help  Show minecraft-bind-backup manual."
  echo
}

# Show help and exit
if [[ $1 == 'help' ]]; then
    Help
    exit
fi

# Process params
while getopts ":c: :p: :o: :r: :d:" opt; do
  case $opt in
    c) CONTAINER="$OPTARG"
    ;;
    p) DATA_PATH="$OPTARG"
    ;;
    o) DIR="$OPTARG"
    ;;
    r) CLEAR="$OPTARG"
    ;;
    d) DAYSBACK="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    Help
    exit;;
  esac
done

# Fallback to environment vars and default values
: ${DIR:='/var/tmp'}
: ${CLEAR:='false'}
: ${DAYSBACK:=0}

# Verify variables
[[ -z "$DATA_PATH" ]] && { echo "Parameter -p|path is empty" ; exit 1; }
[[ -z "$DIR" ]] && { echo "Parameter -d|dir is empty" ; exit 1; }
[[ -z "$CONTAINER" ]] && { echo "Parameter -c|container is empty" ; exit 1; }
[[ ! -d "$DATA_PATH" ]] && { echo "Data directory does not exist: $DATA_PATH" ; exit 1; }
echo "DAYSBACK: $DAYSBACK"

# Create backup folder
mkdir -p ${DIR}/${CONTAINER}

# Delete files older than
if (($DAYSBACK > 0)) ; then
    find ${DIR}/${CONTAINER} -type f -mtime +$DAYSBACK -delete
fi

# Cleanup backup folder
if $CLEAR ; then
    rm -rf ${DIR}/${CONTAINER}/*
fi

BACKUP_FILE="${DIR}/${CONTAINER}/data_$(date '+%Y-%m-%d_%H%M%S').tar"
echo "Run backup for bind mount directory ${DATA_PATH}"
tar cf "${BACKUP_FILE}" -C "${DATA_PATH}" .

# Notify if backup has finished
echo "The bind mount backup has finished: ${BACKUP_FILE}"

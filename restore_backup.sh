#!/bin/bash

# Exit script if command fails
set -e

# Display Help
Help() {
  echo
  echo "minecraft-bind-restore-backup"
  echo "####################"
  echo
  echo "Description: Restore Backups from bind mount tar files."
  echo "Syntax: minecraft-bind-restore-backup [-f|-d|-p|help]"
  echo "Example: minecraft-bind-restore-backup -f data_2026-01-01_000000.tar -d /tmp/Minecraft -p /var/www/minecraft/.data"
  echo "options:"
  echo "  -f    Backup file name."
  echo "  -d    Backups directory."
  echo "  -p    Data directory path."
  echo "  help  Show minecraft-bind-restore-backup manual."
  echo
}

# Show help and exit
if [[ $1 == 'help' ]]; then
    Help
    exit
fi

# Process params
while getopts ":f: :d: :p:" opt; do
  case $opt in
    f) FILE="$OPTARG"
    ;;
    d) DIRECTORY="$OPTARG"
    ;;
    p) DATA_PATH="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    Help
    exit;;
  esac
done

[[ -z "$FILE" ]] && { echo "Parameter -f|file is empty" ; exit 1; }
[[ -z "$DIRECTORY" ]] && { echo "Parameter -d|directory is empty" ; exit 1; }
[[ -z "$DATA_PATH" ]] && { echo "Parameter -p|path is empty" ; exit 1; }
[[ ! -f "$DIRECTORY/$FILE" ]] && { echo "Backup file does not exist: $DIRECTORY/$FILE" ; exit 1; }

mkdir -p "$DATA_PATH"
echo "Start Restore Bind Backup"
tar xvf "$DIRECTORY/$FILE" -C "$DATA_PATH"
echo "Finsh"

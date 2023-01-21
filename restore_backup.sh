#!/bin/bash

# Exit script if command fails
set -e

# Display Help
Help() {
  echo
  echo "docker-volume-restore-backup"
  echo "####################"
  echo
  echo "Description: Restore Backups docker volumes."
  echo "Syntax: docker-volume-restore-backup [-v|-a|-o|-c|help]"
  echo "Example: docker-volume-restore-backup -v postgres_data01 -o /tmp -c postgres01"
  echo "options:"
  echo "  -f    File name docker backup."
  echo "  -c    Docker container name."
  echo "  -d    Backups directory."
  echo "  help  Show docker-volume-restore-backup manual."
  echo
}

# Show help and exit
if [[ $1 == 'help' ]]; then
    Help
    exit
fi

# Process params
while getopts ":c: :f: :d:" opt; do
  case $opt in
    c) CONTAINER="$OPTARG"
    ;;
    f) FILE="$OPTARG"
    ;;
    d) DIRECTORY="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    Help
    exit;;
  esac
done

echo "Start Restore Volume Backup"
docker run --rm --volumes-from $CONTAINER -v $DIRECTORY:/backup bash -c "cd /data && tar xvf /backup/$FILE --strip 1"
echo "Finsh"

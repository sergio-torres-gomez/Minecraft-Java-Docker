#!/bin/bash

source .env

# EXIT script if command fails

set -e

# Display Help
Help() {
 echo
 echo "####################"
 echo
 echo "Description: Restore Backups bind mount Auto."
 echo "Syntax: restaurar_backup.sh [-f|help]"
 echo "options:"
 echo "  -f    Backup file name"
 echo
}


# Show help and exit
if [[ $1 == 'help' ]]; then
    Help
    exit
fi

# Process params
while getopts ":f:" opt; do
  case $opt in
    f) FILE="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    Help
    exit;;
  esac
done

echo "Restauración Automática"

echo "/bin/bash ${ROOT_FOLDER}/restore_backup.sh -p ${ROOT_FOLDER}/${DATA_FOLDER} -d ${ROOT_FOLDER}/${BACKUP_FOLDER}/${CONTAINER_NAME} -f ${FILE}"

/bin/bash ${ROOT_FOLDER}/restore_backup.sh -p ${ROOT_FOLDER}/${DATA_FOLDER} -d ${ROOT_FOLDER}/${BACKUP_FOLDER}/${CONTAINER_NAME} -f ${FILE}

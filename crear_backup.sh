#!/bin/bash

source .env

/bin/bash ${ROOT_FOLDER}/backup.sh -d 7 -p ${ROOT_FOLDER}/${DATA_FOLDER} -c ${CONTAINER_NAME} -r false -o ${ROOT_FOLDER}/${BACKUP_FOLDER}

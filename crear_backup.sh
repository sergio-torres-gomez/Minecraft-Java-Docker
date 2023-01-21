#!/bin/bash

source .env

/bin/bash ${ROOT_FOLDER}/backup.sh -d 7 -v ${VOLUME_NAME} -c ${CONTAINER_NAME} -r false -o ${ROOT_FOLDER}/${BACKUP_FOLDER}

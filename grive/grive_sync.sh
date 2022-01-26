#!/bin/bash
LOG_FILE=/opt/var/grive.log
DOCKER_CONTAINER_NAME=grive
DOCKER_IMAGE_NAME=mygrive
GOOGLE_DRIVE=$HOME/Volumes/GoogleDrive
docker="/opt/homebrew/bin/limactl shell docker docker"
trap "echo Exiting" EXIT

pid=$$

function container_create {
  CONTAINER_CREATE_CMD="${docker} run -d --name ${DOCKER_CONTAINER_NAME} --platform=linux/amd64 --mount type=bind,source=${GOOGLE_DRIVE},target=/home/grive -w /home/grive ${DOCKER_IMAGE_NAME}"

  eval $CONTAINER_CREATE_CMD
}

function main {
	echo "--------------------------"
	echo ${pid}::"$(date)"
	echo "${pid}::PATH:${PATH}"
	
	if [ ! -z "$1" ]
	then
		echo ${pid}::$1
	fi
	
	echo ${pid}::DOCKER_HOST::$DOCKER_HOST
  CONTAINER_ID_CMD="${docker} ps -qa -f name=${DOCKER_CONTAINER_NAME}"
  CONTAINER_ID=$(eval $CONTAINER_ID_CMD)
	
  CONTAINER_RUNNING_CMD="${docker} container inspect ${CONTAINER_ID} -f {{.State.Running}}"
	if [ "$CONTAINER_ID" = "" ]
	then
    echo "Creating container"
		container_create
	elif [ "$(eval ${CONTAINER_RUNNING_CMD})" = "true" ]
	then
		echo ${pid}"::Container ${CONTAINER_ID} is already running, exiting ..."
	else
		echo ${pid}::"Starting container"
    CONTAINER_START_CMD="${docker} start ${CONTAINER_ID}"
		eval $CONTAINER_START_CMD
	fi
}

echo GOOGLE_DRIVE=$GOOGLE_DRIVE
touch $LOG_FILE
if [ -z "$1" ]
then
  echo "No parameter provided"
  main >> $LOG_FILE 2>&1
else
  if [[ "$1" == "trunc"* ]]
  then
  	echo "Truncating the log"
    true > $LOG_FILE
    main >> $LOG_FILE 2>&1
  else
    echo "Appending to the log"
    main $1 >> $LOG_FILE 2>&1
  fi
fi

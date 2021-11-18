#!/bin/bash
BASH_ENV=$HOME/.profile
LOG_FILE=/usr/local/var/grive.log
DOCKER_CONTAINER_NAME=grive
GOOGLE_DRIVE=$HOME/GoogleDrive

trap "echo Exiting" EXIT
shopt -s expand_aliases
source $BASH_ENV

pid=$$

function container_create {
	docker run -d --name $DOCKER_CONTAINER_NAME --mount type=bind,source=$GOOGLE_DRIVE,target=/home/grive -w /home/grive $DOCKER_CONTAINER_NAME
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
	CONTAINER_ID="$(docker ps -qa -f name=${DOCKER_CONTAINER_NAME})"
	
	if [ "$CONTAINER_ID" = "" ]
	then
		container_create
	elif [ "$(docker container inspect ${CONTAINER_ID} -f {{.State.Running}})" = "true" ]
	then
		echo ${pid}"::Container ${CONTAINER_ID} is already running, exiting ..."
	else
		echo ${pid}::"Starting container"
		docker start $CONTAINER_ID
	fi
}

echo GOOGLE_DRIVE=$GOOGLE_DRIVE

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
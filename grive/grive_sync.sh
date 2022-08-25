#!/bin/bash
LOG_FILE=/opt/var/grive.log
DOCKER_CONTAINER_NAME=grive
DOCKER_IMAGE_NAME=mygrive
GOOGLE_DRIVE=$HOME/Volumes/GoogleDrive
docker="/opt/homebrew/bin/limactl shell docker docker"
dockerStart="/opt/homebrew/bin/limactl start docker"
dockerGetStatus="/opt/homebrew/bin/limactl list docker | grep -e \"docker\" | awk ' {FS=\" \"}; {print \$2}'"
dockerStatus=$( eval ${dockerGetStatus} )
dockerLogs="${docker} logs -ft -n 5 ${DOCKER_CONTAINER_NAME}"
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
	echo ${pid}::CONTAINER_ID::$CONTAINER_ID
	
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

	eval $dockerLogs
}

function start_grive {
	if [ -z "$1" ]
	then
		echo "No parameter provided"
		main
		# main >> $LOG_FILE 2>&1
	else
		if [[ "$1" == "trunc"* ]]
		then
			echo "Truncating the log"
			true > $LOG_FILE
			main
			# main >> $LOG_FILE 2>&1
		else
			echo "Appending to the log: ${1}"
			main
			# main $1 >> $LOG_FILE 2>&1
		fi
	fi
}

echo $(date)
echo GOOGLE_DRIVE=$GOOGLE_DRIVE
touch $LOG_FILE

if [ "$dockerStatus" == "" ]
then
	echo "Docker lima VM not found"
elif [ "$dockerStatus" == "Stopped" ]
then
	echo "Starting docker VM"
	$dockerStart
	dockerStatus=$( eval ${dockerGetStatus} )
	if [ "$dockerStatus" == "Running" ]
	then
		echo "Docker is running, starting grive"
		start_grive $1
	else
		echo "Fatal error in docker"	
	fi;
elif [ "$dockerStatus" == "Running" ]
then
	echo "Docker is running, starting grive"
	start_grive $1
else
	echo "Fatal error in docker"
fi



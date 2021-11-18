## lima
# docker with lima on Mac

## setup the docker vm
limactl start ~/projects/lima/docker.yaml

## setup the docker alias
# add alias docker="limactl shell docker docker" to ~/.profile

## build the image for grive
docker build --tag mygrive ~/projects/lima/grive

## initial setup
# edit the file ~/.lima/docker/lima.yaml and allow write on home dir
docker run -it rm --name $DOCKER_CONTAINER --mount type=bind,source=$GOOGLE_DRIVE,target=/home/grive -w /home/grive mygrive grive -a

## subsequent runs

. ~/projects/lima/grive/grive_sync.sh

## view logs
docker logs --follow grive

## crontab 
MAILTO=""
SHELL=/bin/bash
BASH_ENV=$HOME/.profile
*/10 * * * * $HOME/projects/lima/grive/grive_sync.sh crontab
0 0 * * * $HOME/projects/lima/grive/grive_sync.sh trunc
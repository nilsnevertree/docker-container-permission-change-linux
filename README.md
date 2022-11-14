# docker-container-permission-change-linux
With this scripts docker container permissions can be changed to you as the current user. This might solve some issues with permissions if working with volumes in docker run commands.


## Usage

<"bash ~/.docker-container-permission-change-linux/run_container_for_user.sh -d DIRECTORY_PATH_IN_CONTAINER -l DIRECTORY_PATH_LOCAL -c DOCKER_COMMAND

### run_container_for_user.sh
-- Program to start a docker container
and add you as owner of /work
where:
  -l : Path to store container info and commands
  	on your local machine (e.g. .../repository/yourpath)
  -d : Path to store container info and commands
  	in your docker container (e.g. /work/yourpath)
  -c : Docker command to create the container
"
### change_user.sh
!!!!!
ONLY USE INSIDE THE DOCKER CONTAIANER
!!!!!
This file will be run in the docker container using the root user, to creat your local user name in the container:
get the filelocation of the container.cfg from the command line

### get_container.py
Script to create container.cfg and command.cfg which are needed to transfer information from local machine into container.

#### container.cfg 
will contain information of the container that is run by the Dockercommand
#### command.cfg 
contains commands needed to change the folder permissions and users
also contains commands with which the local user can connect to the running container

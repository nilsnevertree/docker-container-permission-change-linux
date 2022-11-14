# docker-container-permission-change-linux
With this scripts docker container permissions can be changed to you as the current user. This might solve some issues with permissions if working with volumes in docker run commands.


## Usage

``` 
bash ~/.docker-container-permission-change-linux/run_container_for_user.sh -d DIRECTORY_PATH_IN_CONTAINER -l DIRECTORY_PATH_LOCAL -c DOCKER_COMMAND
```

`run_container_for_user.sh` calls required docker commands and `get_container.py` which creates `container.cfg` and `commands.cfg` in `DIRECTORY_PATH_LOCAL`. Both files are used by `change_user.sh` which is run inside the container to change premission. If this is done, you can use docker container in the provided shell with the same username as on your local machine. 


### `run_container_for_user.sh`
Program to start a docker container
- l : Path to store container info and commands on your local machine (e.g. .../repository/yourpath) `DIRECTORY_PATH_LOCAL`
- d : Path to store container info and commands in your docker container (e.g. /work/yourpath) `DIRECTORY_PATH_IN_CONTAINER`
- c : Docker command to create the container `DOCKER_COMMAND`

### `change_user.sh`
! ONLY USE INSIDE THE DOCKER CONTAIANER !

This file will be run in the docker container using the root user, to creat your local user name in the container: get the filelocation of the container.cfg from the command line

### `get_container.py`
Script to create container.cfg and command.cfg which are needed to transfer information from local machine into container.

#### `container.cfg`
Will be created in `DIRECTORY_PATH_LOCAL` and contain information of the container that is run by the Dockercommand
#### `command.cfg` 
Will be created in `DIRECTORY_PATH_LOCAL` and contains commands needed to change the folder permissions and users. Also contains commands with which the local user can connect to the running container

#!/bin/bash
#

usage="$(basename "$0") [-d] [-l]
-- Program to start a docker container
and add you as owner of /work
where:
  -l : Path to store container info and commands
  	on your local machine (e.g. .../repository/yourpath)
  -d : Path to store container info and commands
  	in your docker container (e.g. /work/yourpath)
  -c : Docker command to create the container
"

# This file helps  you to properly run a docker container with read and write priveleges:
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# the paths for the folders containing the informations need to be
while getopts ":hd:l:c:" flag; do
    case "${flag}" in
    	h) echo "$usage"
    	exit
    	;;
        d) DirDocker=${OPTARG}
        ;;
        l) DirLocal=${OPTARG}
        ;;
        c) DockerCommand=${OPTARG}
        ;;
    	?) printf "Usage: %s: [-d path] [-l path] [-c docker command] args\n"
          exit 2
          ;;
    esac
done

echo -e "-----"
if [ -z "$DirLocal" ]
then
    echo "-l argument not supplied" >&2
    exit 1
else
    echo -e "DirLocal:\n$DirLocal"
fi

if [ -z "$DirDocker" ]
then
    echo "-d argument not supplied" >&2
    exit 1
else
    echo -e "DirDocker:\n$DirDocker"
fi

if [ -z "$DockerCommand" ]
then
    echo "-c argument not supplied" >&2
    exit 1
else
    echo -e "DockerCommand:\n$DockerCommand"
fi
echo -e "-----"



#DirLocal='/home/student/repositories/climate_index_collection/.nils_docker_connection'
#DirDocker='/work/.nils_docker_connection'
# the commands will be stored in these files
CommandFileLocal="${DirLocal}/commands.cfg"
CommandFileDocker="${DirDocker}/commands.cfg"

# location of the change_user.sh script on the local machine.
# Should be in the same folder as this script.
ChangeUserScript="${SCRIPT_DIR}/change_user.sh"
GetContainerPy="${SCRIPT_DIR}/get_container.py -l ${DirLocal} -d ${DirDocker}"

# --- 0 ---
# Start the docker container
gnome-terminal -- /bin/sh -c "echo 'IMPORTANT\nIf you close this window, container will be shut down!\n-----';${DockerCommand} ; bash"


# --- 1 ---
# first we need to start the contianer in a new shell
#gnome-terminal
echo -e "If docker container is created, press Enter."
read -p "Otherwise Ctrl+C to stop the script." input
echo -e "-----"

# --- 2 ---
# Copy newest version of change_user.sh into '${DirLocal}'
echo -e "Copy newest version of change_user.sh into \n'${DirLocal}'"
cp ${ChangeUserScript} ${DirLocal}
echo -e "-----"

# --- 3 ---
# Call the python script to get container information and create files:\n -commands.cfg\n -container.cfg
echo -e "Call the python script to get container information and create files:\n -commands.cfg\n -container.cfg"
python ${GetContainerPy}
echo -e "-----"

# --- 4 ---
# now lets get the three availabel commmands created by the python script
# - root_userchange :
#    Command, which is needed to create to current user in the container and change privileges
# - user_jupyter :
#    Command used to create a jupyter server in the container as the user which executes the script
# - user_bash :
#    Command to call a bash shell in the container
echo -e "Getting available commands from commands.cfg"
root_userchange=$(sed '1q;d' $CommandFileLocal)
user_jupyter=$(sed '2q;d' $CommandFileLocal)
user_bash=$(sed '3q;d' $CommandFileLocal)
echo -e " ${root_userchange}, \n ${user_jupyter}, \n ${user_bash}"
echo -e "-----"

# --- 5 ---
echo -e "Run the change_user.sh to create the user and change privileges"
gnome-terminal -- /bin/sh -c "echo 'Running change_user.sh inside container.\nWait until its done before you proceed in the other shells!\n-----\n'; ${root_userchange}; sleep 5"
# --- 6 ---
# open a shell for the user to work in.
# We need to wait for a few seconds before the change_user.sh file is properly executed
echo -e "Open bash for the user"
gnome-terminal -- /bin/sh -c "echo 'Your shell to work in the Container\n-----\n'; sleep 1; ${user_bash}"
# --- 7 ---
echo -e "-----"
echo -e "DONE! You can now use the container properly in the shell provided or by calliing one of the provided commands."

echo 'Done'

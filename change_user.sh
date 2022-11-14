#!/bin/bash

# !!!!!
# ONLY USE INSIDE THE DOCKER CONTAIANER
# !!!!!

show_output () {
	if [$1 -eq 0]; then
	    printf 'Sucessfull\n'
	else
	    printf 'Error:\n«%s»' "$1"
	fi
}


# This file will be run in the docker container using the root user, to creat your local user name in the container:
# get the filelocation of the container.cfg from the command line
while getopts "f:" flag; do
    case "${flag}" in
        f) file=${OPTARG};;
    esac
done
echo $file
cid=$(sed '1q;d' $file)
uname=$(sed '2q;d' $file)
uid=$(sed '3q;d' $file)
gituname=$(sed '4q;d' $file)
gitemail=$(sed '5q;d' $file)
groups='jovyan,root,sudo,users'
jovyanpath='/home/jovyan/'

echo -e  '\nYou are:' "'"$uname':'$uid"'"

# Add the user specified in the config file
echo -e 'Add ' "'"$uname':'$uid"'" ' to container' "'"$cid"'"
output=$(useradd -u $uid $uname)

# Add new user to all the groups specified
echo -e 'Add' "'"$uname':'$uid"'" 'to groups:' "'"$groups"'"
output=$(usermod -a -G $groups $uname)

# Change ownership of jovyanpath
echo -e 'Change' "'"$jovyanpath"'" 'ownership to' "'"$uname':'$uid"'"
output=$(chown -R $uname $jovyanpath)
output=$(chgrp -R $uname $jovyanpath)
output=$(chown -R "$uname":"$uid" $jovyanpath)

# The stuff below is unnecessary as these commands will be created by the get_container.py script
# and will be written in the commands.cfg file.
# # echo the commands that can be executed
# echo -e '\n----\nRun the following command in a new shell to connect to the container:'
# echo -e '- Jupyter server:'
# echo -e 'docker exec -ti --user' $uname $cid 'jupyter lab --ip=0.0.0.0'
# echo -e '- Bash shell:'
# echo -e 'docker exec -ti --user' $uname $cid 'bash'

echo -e "DONE"

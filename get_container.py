#%%
#!/usr/bin/python

import getopt
import subprocess
import sys

from os import path


def main(argv):
    inputfile = ""
    outputfile = ""
    try:
        opts, args = getopt.getopt(argv, "hl:d:", ["l=", "d="])
    except getopt.GetoptError:
        print("get_container.py -l <LocalPath> -d <DockerPath>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == "-h":
            print("get_container.py -l <LocalPath> -d <DockerPath>")
            sys.exit()
        elif opt in ("-l", "--localpath", "--LocalPath"):
            FOLDER_PATH_LOCAL = arg
        elif opt in ("-d", "--dockerpath", "--DockerPath"):
            FOLDER_PATH_DOCKER = arg
    #print('LocalPath is "', FOLDER_PATH_LOCAL)
    #print('DockerPath is "', FOLDER_PATH_DOCKER)

    # please note, that both folders need to containe the same structure!
    CONFIG_PATH_LOCAL = path.join(FOLDER_PATH_LOCAL, "container.cfg")
    CONFIG_PATH_DOCKER = path.join(FOLDER_PATH_DOCKER, "container.cfg")
    COMMAND_PATH_LOCAL = path.join(FOLDER_PATH_LOCAL, "commands.cfg")
    CHANGE_USER_DOCKER = path.join(FOLDER_PATH_DOCKER, "change_user.sh")

    def get_command(bashCommand):
        process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()
        return output, error

    # get docker container id
    output, error = get_command("docker ps -n=-1")
    containerid = str(output).split(r"\n")[1].split()[0]
    if len(containerid) <= 1:
        raise Exception("No container running!")
    print("------\nThe docker container id is:")
    print(f"{containerid}")
    if input("Is that correct? (y/n)\n") == "y":
        pass
    else:
        raise Exception("Not the correct container.")
    output, error = get_command("whoami")
    username = str(output, "utf-8")[0:-1]

    output, error = get_command(f"id -u {username}")
    userid = str(output, "utf-8")[0:-1]

    print("\nYour username:userid will be created in the new docker container:")
    print(f"{username}:{userid}")

    output, error = get_command("git config --list")
    git_config = str(output, "utf-8")[0:-1]
    git_config = dict([e.split("=") for e in git_config.split("\n")])
    print("\nYour git credentials will be included in the container repository:")
    print(git_config["user.name"])
    print(git_config["user.email"])

    # write config file
    with open(CONFIG_PATH_LOCAL, "w") as f:
        f.write(containerid)
        f.write("\n")
        f.write(username)
        f.write("\n")
        f.write(userid)
        f.write("\n")
        f.write(git_config["user.name"])
        f.write("\n")
        f.write(git_config["user.email"])
    # write file with the command to connect to the docker container
    with open(COMMAND_PATH_LOCAL, "w") as f:
        f.write(
            f"docker exec -ti --user root {containerid} bash {CHANGE_USER_DOCKER} -f {CONFIG_PATH_DOCKER}"
        )
        f.write("\n")
        f.write(
            f"docker exec -ti --user {username} {containerid} jupyter lab --ip=0.0.0.0"
        )
        f.write("\n")
        f.write(f"docker exec -ti --user {username} {containerid} bash")

    # bashCommand_root =
    # bashCommand_user = f"docker exec -ti --user {username} {containerid} jupyter lab --ip=0.0.0.0"
    # f.write('\n')
    # f.write(f"docker exec -ti --user {username} {containerid} bash")


if __name__ == "__main__":
    main(sys.argv[1:])

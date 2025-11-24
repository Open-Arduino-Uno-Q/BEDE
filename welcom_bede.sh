#!/bin/bash

echo "#####################"
echo " Welcom To the Embedded Builder"
echo " By Nakada Tokumei "
echo "#####################"

user_uid=$(id -u)
user_gid=$(id -g)
docker_name="unoq_builder_${user_uid}_${user_gid}"
workspace_dir=""

launch_docker="false"
terminate_docker="false"


function update_workspace_path() {
	if [ -f $HOME/.unoq_builder/directory ];then
        	workspace_dir=`cat $HOME/.unoq_builder/directory`
	fi
}

function run_docker() {
    echo 'sudo docker run --privileged -h unoq_builder --name ${docker_name} -t -it -d -p 12346 -v $HOME/.unoq_builder/go:/usr/local/go -v $HOME/.unoq_builder/pkg:/pkg -v $HOME/.ssh:/home/unoqbuild/.ssh -v $workspace_dir:/home/unoqbuild/workspace -v /dev/:/dev -v /run/udev:/run/udev unoq_builder:24.04 /usr/sbin/sshd -D'
    sudo docker run --privileged -h unoq_builder --name ${docker_name} -t -it -d -p 12346:22 -v $HOME/.unoq_builder/go:/usr/local/go -v $HOME/.unoq_builder/pkg:/pkg -v $HOME/.ssh:/home/unoqbuild/.ssh -v $workspace_dir:/home/unoqbuild/workspace -v /dev/:/dev -v /run/udev:/run/udev unoq_builder:24.04 /usr/sbin/sshd -D
}

function set_docker_env() {
	sudo docker exec -it ${docker_name} userdel -r ubuntu
	sudo docker exec -it ${docker_name} groupdel ubuntu
	sudo docker exec -it ${docker_name} groupadd -g ${user_gid} unoqbuild
	sudo docker exec -it ${docker_name} useradd -u ${user_uid} -g ${user_gid} -ms /bin/bash unoqbuild
	sudo docker exec -it ${docker_name} chown ${user_uid}:${user_gid} /home/unoqbuild
	sudo docker exec -it ${docker_name} sh -c 'echo "export LC_ALL=en_US.UTF-8" >> /home/unoqbuild/.bashrc'
	sudo docker exec -it ${docker_name} sh -c 'echo "export LANG=en_US.UTF-8" >> /home/unoqbuild/.bashrc'
	sudo docker exec -it ${docker_name} sh -c 'echo "unoqbuild:ubuntu" | chpasswd'
	sudo docker exec -it -u ${user_uid}:${user_gid} -w /home/unoqbuild ${docker_name} sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function exec_docker() {
	echo "sudo docker exec -it -u ${user_uid}:${user_gid} -w /home/unoqbuild ${docker_name} /bin/zsh"
	sudo docker exec -it -u ${user_uid}:${user_gid} -w /home/unoqbuild ${docker_name} /bin/zsh
}

function kill_docker() {
	sudo docker kill ${docker_name}
	sudo docker rm ${docker_name}
}

function start_docker() {
	running_container=`sudo docker ps -a | awk '{print $NF}' | grep -w ${docker_name}`
	if [ $launch_docker != "false" ]; then
		if [ "$running_container" = "" ]; then
			update_workspace_path
			run_docker
			set_docker_env
		fi
		exec_docker
	fi

	if [ $terminate_docker != "false" ]; then
		if [ "$running_container" != "" ]; then
			kill_docker
		else
			echo "Failed to kill: Docker not exist."
		fi
	fi
}


if [ $# != 0 ]; then
	while true; do
		case "$1" in
			-k|--kill)
				launch_docker="false"
				terminate_docker="true"
				break
				;;
			*)
				echo "Launching Docker..."
				launch_docker="true"
				;;
		esac
		shift

		if [ "$1" = "" ]; then
			break
		fi
	done
else
	launch_docker="true"
fi

start_docker


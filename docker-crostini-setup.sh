check_for_os() {
	unset OS
	unset OSV
	unset CROS
	if [ -d /mnt/chromeos ]  && [ -d /dev/lxd ] && [ -f /opt/google/cros-containers/bin/garcon ]; then
	       CROS="yes"
        fi	       
	# Check if we are linux or OSX
	if [ -n "$(uname -o | grep Darwin)" ]; then
		echo "OSX not supported"
		exit 1
	elif [ -x `which lsb_release` ]; then
		OS=`lsb_release -is`
		OSV=`lsb_release -cs`
	else
		echo "Unsupported OS"
		exit 1

	fi	

}

get_docker() {
	sudo apt-get install \
     		apt-transport-https \
     		ca-certificates \
     		curl \
     		gnupg2 \
     		software-properties-common -y

	curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr \"[:upper:]\" \"[:lower:]\")/gpg | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr \"[:upper:]\" \"[:lower:]\") $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list'

	sudo apt-get update
	sudo apt-get install docker-ce -y
	me=`whoami`
	sudo usermod -aG docker ${me}
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -fsSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo curl -fsSL "https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose" -o /etc/bash_completion.d/docker-compose

}

check_for_os
sudo apt-get update
sudo apt-get upgrade -y
cd ~
get_docker
#!/bin/sh

rm -rf dotfiles
git clone --recursive https://github.com/hillyu/hill.git dotfiles \
&& bash ~/dotfiles/bin/bootstrap.sh ~/dotfiles
sed -i 's/ash/zsh/g' /etc/passwd
wget https://github.com/docker/compose/releases/download/1.25.5/docker-compose-Linux-x86_64 \
    && mv docker-compose-Linux-x86_64 /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	# add our default arguments
	set -- dockerd \
		--host=unix:///var/run/docker.sock \
		--host=tcp://0.0.0.0:2375 \
		"$@"
fi
exec "$@"

#!/bin/sh

sudo chown -R hill:hill dotfiles
rm -rf dotfiles
git clone --recursive https://github.com/hillyu/hill.git dotfiles \
&& bash ~/dotfiles/bin/bootstrap.sh ~/dotfiles
#sed -i 's/bash/zsh/g' /etc/passwd
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	# add our default arguments
	set -- sudo dockerd \
		--host=unix:///var/run/docker.sock \
		--host=tcp://0.0.0.0:2375 \
		"$@"
fi
exec "$@"

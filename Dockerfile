arg base="nvidia/cuda:10.1-runtime" 
from $base
# following args can be seen from inside of the build container
arg ubuntu_pkg="build-essential vim htop zsh git curl bash tmux wget python3-pip nvidia-container-toolkit nvidia-docker2 docker-ce"


#add requirements.txt requirements.txt

# install packages
run echo "|--> install basics pre-requisites" && \
        pkg_install_cmd="apt-get install -yq"; \
        pkg_upgrade_cmd="apt-get update"; \
        pkg_clean_cmd="apt-get clean"; \
        distro_pkg="${ubuntu_pkg}"; \
        #[ ! -z "${distro_mirror}" ] && sed -i \
        #"s/deb.debian.org/${distro_mirror}/g" /etc/apt/sources.list ||:; \
        ${pkg_upgrade_cmd} && ${pkg_install_cmd} apt-transport-https ca-certificates curl gnupg2 software-properties-common ;\
        update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1; \
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -; \
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"; \
        apt update; \
        apt-cache policy docker-ce; \
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID); \
        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -; \
        curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list; \
    eval "${pkg_upgrade_cmd}" \
    && ${pkg_install_cmd} ${distro_pkg} \
    && echo "|--> cleaning" \
    && rm -rf /root/.cache \
    && rm -rf /root/.[acpw]* \
    && rm -rf /var/lib/apt/lists \ 
    && find /usr/lib/ -name __pycache__ | xargs rm -rf \
    && ${pkg_clean_cmd} \
    && echo "|--> done!" 

run mkdir /home/hill
workdir /home/hill 
env HOME=/home/hill
run git clone --recursive https://github.com/hillyu/hill.git dotfiles \
    && bash ~/dotfiles/bin/bootstrap.sh ~/dotfiles
run sed -i 's/ash/zsh/g' /etc/passwd
add ./entrypoint.sh ./
entrypoint ["/home/hill/entrypoint.sh"]
expose ${port_to_expose}

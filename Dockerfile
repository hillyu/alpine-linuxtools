arg base="python:3-alpine" 
from $base
# following args can be seen from inside of the build container
arg distro_mirror
arg pypi_mirror
ARG distro_pkg
#alpine
ARG alpine_pkg="build-base vim htop zsh git curl bash openssh tmux docker zsh-vcs"  
#buster
arg debian_pkg="build-essential vim htop zsh git curl bash tmux nvidia-container-toolkit docker-ce"
#arg distro_deps="make automake g++ linux-headers cmake"
arg distro_deps="make automake g++ linux-headers"
arg port_to_expose=8080


add requirements.txt requirements.txt

# install packages
run echo "|--> install basics pre-requisites" \
    && if [ ! -z `which apk` ]; then \
        pkg_install_cmd="apk add --no-cache"; \
        pkg_upgrade_cmd="apk update"; \
        pkg_clean_cmd="apk del .build-deps"; \
        distro_pkg="${alpine_pkg}"; \
        [ ! -z "${distro_mirror}" ] && sed -i \
        "s/dl-cdn.alpinelinux.org/${distro_mirror}/g" /etc/apk/repositories || :; fi \
    && if [ ! -z `which apt-get` ]; then \
        pkg_install_cmd="apt-get install -y"; \
        pkg_upgrade_cmd="apt-get update"; \
        pkg_clean_cmd="apt-get clean"; \
        distro_pkg="${debian_pkg}"; \
        [ ! -z "${distro_mirror}" ] && sed -i \
        "s/deb.debian.org/${distro_mirror}/g" /etc/apt/sources.list ||:; \
        apt update && apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common ;\
        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -; \
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"; \
        apt update; \
        apt-cache policy docker-ce; \
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID); \
        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -; \
        curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list; \
        apt-get update && apt-get install -y nvidia-container-toolkit; fi \

    && eval "${pkg_upgrade_cmd}" \
    && ${pkg_install_cmd} ${distro_pkg} \
    && echo "|--> install build dependencies" \
    && [ ! -z `which apk` ] && ${pkg_install_cmd} --virtual=.build-deps \
        ${distro_deps} ||:\
    && echo "|--> install python packages(numpy,pandas,grpc)" \ 
    && [ ! -z "${pypi_mirror}" ] && pip config set global.index-url "${pypi_mirror}" ||:\
    &&  pip install -U --no-cache-dir -r requirements.txt \
    && echo "|--> cleaning" \
    && rm -rf /root/.cache \
    && rm -rf /root/.[acpw]* \
    #&& rm -rf /var/cache/apk \ 
    #&& rm -rf /var/lib/apt/lists \ 
    && find /usr/lib/ -name __pycache__ | xargs rm -rf \
    && ${pkg_clean_cmd} \
    && echo "|--> done!" \
    && echo "|--> Configure Jupyter extension" \
    && jupyter nbextension enable --py widgetsnbextension \
    && mkdir -p ~/.ipython/profile_default/startup/ \
    && echo "import warnings" >> ~/.ipython/profile_default/startup/config.py \
    && echo "warnings.filterwarnings('ignore')" >> ~/.ipython/profile_default/startup/config.py \
    && echo "c.NotebookApp.token = u''" >> ~/.ipython/profile_default/startup/config.py \
    && echo "|--> Done!"

run mkdir /home/hill
workdir /home/hill 
env HOME=/home/hill
run git clone --recursive https://github.com/hillyu/hill.git dotfiles \
    && bash ~/dotfiles/bin/bootstrap.sh ~/dotfiles
run sed -i 's/ash/zsh/g' /etc/passwd
#run vim +'pluginstall --sync' +qa >/dev/null 2>/dev/null &
#cmd ["jupyter", "notebook", "--port=5000", "--no-browser", \
    #"--allow-root", "--ip=0.0.0.0", "--notebookapp.token="]
add ./entrypoint.sh ./
entrypoint ["/home/hill/entrypoint.sh"]
CMD ["jupyter", "notebook", "--port=8080", "--no-browser", \
    "--allow-root", "--ip=0.0.0.0", "--NotebookApp.token="]
# port
expose ${port_to_expose}

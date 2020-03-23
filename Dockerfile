ARG base="hillyu/notebook:latest" 
FROM ${base}
ARG USE_MIRROR
ARG alpine_packages="build-base vim htop zsh git curl bash openssh tmux"
#ARG alpine_packages
#ARG alpine_deps
ARG python_packages="ranger"
ENV HOME="/home/hill"

RUN echo "|--> Updating" \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/main | tee /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing | tee -a /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories
RUN [ "$USE_MIRROR" = "true" ] && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ||echo "$USE_MIRROR";
RUN echo "|--> Install Alpine-supported packages (from edge repo)" \
    && apk update && apk upgrade \
    && apk add --no-cache ${alpine_packages}\
    && echo "|--> Install build dependencies(to-be-removed later)" \
    && apk add --no-cache --virtual=.build-deps \
        ${alpine_deps}\
    && echo "|--> Install Python packages"; 
RUN pip install -U --no-cache-dir ${python_packages} \
        $([ "$USE_MIRROR" = "true" ] && echo "-i https://pypi.douban.com/simple" ||:) \
    && echo "|--> Cleaning" \
    && rm -rf /root/.cache \
    && rm -rf /root/.[acpw]* \
    && rm -rf /var/cache/apk/* \
    && find /usr/lib/ -name __pycache__ | xargs rm -rf \
    && apk del .build-deps \
    && echo "|--> Done!"

RUN mkdir /home/hill
WORKDIR /home/hill 
RUN git clone --recursive https://github.com/hillyu/hill.git dotfiles \
    && bash ~/dotfiles/bin/bootstrap.sh ~/dotfiles
#CMD ["jupyter", "notebook", "--port=5000", "--no-browser", \
    #"--allow-root", "--ip=0.0.0.0", "--NotebookApp.token="]

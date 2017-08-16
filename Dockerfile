FROM mcchae/ide
MAINTAINER MoonChang Chae mcchae@gmail.com
LABEL Description="alpine desktop env with conda (over xfce with novnc, xrdp and openssh server)"

################################################################################
# need glibc instead of musl libc
################################################################################
RUN apk --update  --repository http://dl-4.alpinelinux.org/alpine/edge/community add \
    bash \
    git \
    curl \
    ca-certificates \
    bzip2 \
    unzip \
    sudo \
    libstdc++ \
    glib \
    libxext \
    libxrender \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk" -o /tmp/glibc.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.25-r0/glibc-bin-2.25-r0.apk" -o /tmp/glibc-bin.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.25-r0/glibc-i18n-2.25-r0.apk" -o /tmp/glibc-i18n.apk \
    && apk add --allow-untrusted /tmp/glibc*.apk \
    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    && /usr/glibc-compat/bin/localedef -i ko_KR -f UTF-8 ko_KR.UTF-8 \
    && rm -rf /tmp/glibc*apk /var/cache/apk/*

################################################################################
# package prepare for pyenv
################################################################################
RUN apk add --no-cache --update \
      bash \
      build-base \
      ca-certificates \
      git \
      bzip2-dev \
      linux-headers \
      openssl \
      openssl-dev \
      ncurses-dev \
      readline-dev \
      sqlite-dev \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

################################################################################
# pyenv install
################################################################################
# next pyenv need bash
RUN mkdir -p /usr/local/toor && chown -R toor:toor /usr/local/toor \
    && rm /bin/sh && ln -s /bin/bash /bin/sh
USER toor
ENV HOME=/usr/local/toor \
    SHELL=/bin/bash
WORKDIR /home/toor
#ENV PYTHON_VERSION=${PYTHON_VERSION:-3.5.3}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.6.2}
ENV PYENV_ROOT=${HOME}/.pyenv
ENV PATH=${PYENV_ROOT}/bin:${PATH}
RUN  curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer -o ${HOME}/pyenv-installer.sh \
    && touch ${HOME}/.bashrc \
    && /bin/bash -x ${HOME}/pyenv-installer.sh \
    && rm -f ${HOME}/pyenv-installer.sh \
    # Create a file of the pyenv init commands
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /tmp/pyenvinit \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /tmp/pyenvinit \
    && echo 'eval "$(pyenv init -)"' >> /tmp/pyenvinit \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> /tmp/pyenvinit \
    && source /tmp/pyenvinit \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pip install --upgrade pip \
    && pyenv rehash \
    && git clone git://github.com/kennethreitz/autoenv.git ${HOME}/.autoenv


################################################################################
# main
################################################################################
USER root
ADD chroot/usr /usr
#RUN cp -R ${HOME}/.pyenv /usr/local/toor
WORKDIR /
ENV HOME=/home/toor \
    SHELL=/bin/bash
ENTRYPOINT ["bash", "/startup.sh"]

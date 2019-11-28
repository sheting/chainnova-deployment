FROM alpine:3.6
MAINTAINER chainnova <hwc@chainnova.com>

ENV HOME /root

RUN apk update &&\
    apk add --no-cache --virtual\
    .build-deps \
    bash \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev

WORKDIR /root

#下载解压
RUN curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.39.tar.gz -o libfastcommon.tar.gz &&\
    #curl -fSL https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.11 -o fastfs.tar.gz &&\
    curl -fSL https://github.com/happyfish100/fastdfs/archive/V5.11.tar.gz -o fastfs.tar.gz &&\
    tar zxf libfastcommon.tar.gz &&\
    tar zxf fastfs.tar.gz

#安装libfastcommon
RUN cd ${HOME}/libfastcommon-1.0.39 &&\
    ./make.sh &&\
    ./make.sh install

RUN echo 'export LC_ALL=C'>>~/.bashrc

#安装fastDFS
RUN cd ${HOME}/fastdfs-5.11 &&\
    ./make.sh &&\
    ./make.sh install

RUN mkdir -p /home/fastdfs/tracker /home/fastdfs/storage /home/fastdfs/client

RUN     cd /etc/fdfs/ \
        && cp storage.conf.sample storage.conf \
        && cp tracker.conf.sample tracker.conf \
        && cp client.conf.sample client.conf \
        && sed -i "s|/home/fastdfs/tracker|/var/local/fdfs/tracker|g" /etc/fdfs/tracker.conf \
        && sed -i "s|/home/fastdfs/storage|/var/local/fdfs/storage|g" /etc/fdfs/storage.conf \
        && sed -i "s|/home/fastdfs/client|/var/local/fdfs/storage|g" /etc/fdfs/client.conf

# 清理文件
#RUN rm -rf ${HOME}/*
RUN apk del .build-deps gcc libc-dev make openssl-dev linux-headers curl gnupg libxslt-dev gd-dev geoip-dev
RUN apk add bash pcre-dev zlib-dev

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

#ENV HTTP_PORT 22123
ENV TRACKER_WEB_PORT 22121
ENV TRACKER_PATH /home/fastdfs/tracker
ENV FDFS_PORT 22120

ENV WEB_PORT 22123
ENV STORAGE_PATH /home/fastdfs/storage
ENV STORAGE_PORT 22122
ENV STORAGE_PATH0 /home/fastdfs/storage/file

EXPOSE 80 22120 22121 22122 22123

#ENTRYPOINT ["/bin/bash","/docker-entrypoint.sh"]

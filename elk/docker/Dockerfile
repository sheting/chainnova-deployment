FROM alpine:3.8
RUN echo -e 'http://mirrors.ustc.edu.cn/alpine/v3.8/main\nhttp://mirrors.ustc.edu.cn/alpine/v3.8/community\n' > /etc/apk/repositories
RUN apk add --update --no-cache coreutils \
    bash \
    curl \
    && rm -rf /var/cache/apk/*
#RUN apk add --no-cache \
#    bash \
#    curl 
COPY ./es-cronjob-script /home/es-cronjob-script
RUN chmod +x /home/es-cronjob-script/*

ENTRYPOINT ["/bin/bash"]

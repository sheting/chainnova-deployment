FROM alpine:3.7

RUN echo -e 'http://mirrors.tuna.tsinghua.edu.cn/alpine/v3.7/main\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/v3.7/community' > /etc/apk/repositories
RUN apk add --no-cache \
    bash \
    coreutils \
    apache2-utils \
    gomplate \
#    libxml2-utils \
    perl-xml-xpath

WORKDIR /home

ENTRYPOINT ["/bin/bash"]

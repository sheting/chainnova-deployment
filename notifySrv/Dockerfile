FROM golang:1.9.1-alpine3.6 as builder

RUN mkdir -p /go/src/github.com/chainnova/ci/notifySrv

WORKDIR /go/src/github.com/chainnova/ci/notifySrv

COPY . /go/src/github.com/chainnova/ci/notifySrv 

RUN cd /go/src/github.com/chainnova/ci/notifySrv && \
	pwd && ls -al && \
	rm -f notifySrv && \
	go build -v notifySrv.go && \
	ls -l |grep -E "\s+notifySrv$" && \
	chmod +x notifySrv

FROM alpine:3.6

RUN echo -e 'http://mirrors.ustc.edu.cn/alpine/edge/main\nhttp://mirrors.ustc.edu.cn/alpine/edge/community\nhttp://mirrors.ustc.edu.cn/alpine/edge/testing' > /etc/apk/repositories
RUN apk add --no-cache \
    bash 

RUN mkdir -p /go/src/github.com/chainnova/ci/notifySrv

WORKDIR /home

COPY --from=builder /go/src/github.com/chainnova/ci/notifySrv/notifySrv /home
COPY --from=builder /go/src/github.com/chainnova/ci/notifySrv/config      /home/config

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["./notifySrv"]

EXPOSE 30222

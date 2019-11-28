ARG BASE_TAG
ARG BASE_REPOSITORY
FROM ${BASE_REPOSITORY}:${BASE_TAG} as builder
ARG WDIR

COPY . /go/src/chainnova.com/${WDIR}

ENV CGO_ENABLED=0

RUN cd /go/src/chainnova.com/${WDIR} && \
    rm -f ${WDIR} && \
    go build -v && \
    ls -l | grep -E "\s+${WDIR}$"



FROM ${BASE_REPOSITORY}:${BASE_TAG}
ARG MODE_TYPE
ARG WDIR
ARG PORT

ENV WDIR=${WDIR}
ENV MODE_TYPE=${MODE_TYPE}

COPY --from=builder /go/src/chainnova.com/${WDIR}/${WDIR} /home
COPY --from=builder /go/src/chainnova.com/${WDIR}/conf        /home/conf
COPY --from=builder /go/src/chainnova.com/${WDIR}/chaincode        /home/chaincode

WORKDIR /home
VOLUME ["/home/logs"]

ENTRYPOINT ["/bin/bash"]
CMD ["-c", "./${WDIR} ${MODE_TYPE}"]

EXPOSE ${PORT}

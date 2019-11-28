ARG BASE_REPOSITORY
ARG BASE_TAG

FROM ${BASE_REPOSITORY}:${BASE_TAG}

ARG PORT
RUN mkdir -p /home/app

COPY . /home/app

RUN cd /home/app && \
    rm -rf node_modules && \
    mv node_modules_mirror node_modules && \
    npm i && \
    npm rebuild &&\
    cd -

WORKDIR /home/app

ENTRYPOINT ["/bin/bash"]

EXPOSE ${PORT}

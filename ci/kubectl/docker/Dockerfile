ARG BASE_REPOSITORY
ARG BASE_TAG
FROM ${BASE_REPOSITORY}:${BASE_TAG}

RUN echo 'StrictHostKeyChecking no'>>/etc/ssh/ssh_config

COPY ./docker/config /root
#COPY ./docker/kubectl_hw /usr/local/bin/kubectl
#RUN chmod +x /usr/local/bin/kubectl

WORKDIR /home

ENTRYPOINT ["/bin/bash"]

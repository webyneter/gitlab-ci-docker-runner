FROM docker:18

COPY ./requirements/ /requirements/
RUN \
# region Ansible
# (from https://github.com/William-Yeh/docker-ansible/blob/master/alpine3/Dockerfile
# with slight modifications)
    echo "===> Installing sudo to emulate normal OS behavior..."  && \
    apk --update add sudo && \
    echo "===> Adding Python runtime..." && \
    apk add python py-pip openssl ca-certificates && \
    apk add --virtual build-dependencies python-dev libffi-dev openssl-dev build-base && \
    pip install --upgrade pip cffi && \
    echo "===> Installing Ansible..."  && \
    pip install --no-cache-dir --requirement /requirements/ansible.txt && \
    echo "===> Removing package list..."  && \
    apk del build-dependencies && \
# endregion
    # OpenSSH
    apk add openssh && \
    # Docker Compose (https://gitlab.com/gitlab-org/gitlab-ce/issues/30426#note_37452055)
    apk add py-pip && \
    pip install --no-cache-dir --requirement /requirements/docker-compose.txt && \
    # bash
    apk add bash && \
    # curl
    apk add curl && \
    # AWS CLI (https://github.com/mesosphere/aws-cli/blob/master/Dockerfile)
    apk add less groff mailcap && \
    pip install --no-cache-dir --requirement /requirements/awscli.txt && \
    # cleanup
    rm -rf /requirements/ && \
    apk --verbose --purge del py-pip && \
    rm -rf /var/cache/apk/*

# https://docs.ansible.com/ansible/2.6/reference_appendices/config.html#the-configuration-file
COPY ansible.cfg /root/.ansible.cfg

COPY ./scripts/ /usr/local/bin/scripts/
RUN find /usr/local/bin/scripts/ -type f -exec sed -i 's/\r//' {} \;
RUN chmod +x /usr/local/bin/scripts/*
RUN mv /usr/local/bin/scripts/* /usr/local/bin/ \
    && rmdir /usr/local/bin/scripts/

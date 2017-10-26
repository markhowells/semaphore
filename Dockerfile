FROM alpine:3.5

ENV SEMAPHORE_VERSION="2.4.1" SEMAPHORE_ARCH="linux_amd64"
ENV ANSIBLE_VERSION="2.4.1.0"
ENV DIGITALOCEAN="digital_ocean"


RUN apk add --no-cache git ansible mysql-client curl openssh-client tini && \
    curl -sSfL "https://github.com/ansible-semaphore/semaphore/releases/download/v$SEMAPHORE_VERSION/semaphore_$SEMAPHORE_ARCH" > /usr/bin/semaphore && \
    chmod +x /usr/bin/semaphore && mkdir -p /etc/semaphore/playbooks

EXPOSE 3000

ADD ./scripts/docker-startup.sh /usr/bin/semaphore-startup.sh
ADD https://releases.ansible.com/ansible/ansible-$ANSIBLE_VERSION.tar.gz /tmp/
RUN tar xvz -C /tmp -f ansible-ANSIBLE_VERSION.tar.gz
RUN tar xv -C /tmp/dist -f ansible-$ANSIBLE_VERSION.tar
RUN cp /tmp/dist/contrib/inventory/$DIGITALOCEAN/* /etc/ansible
RUN chmod 644 /etc/ansible/$DIGITALOCEAN.ini
RUN chmod +x /etc/ansible/$DIGITALOCEAN.py
RUN chmod +x /usr/bin/semaphore-startup.sh

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/bin/semaphore-startup.sh", "/usr/bin/semaphore", "-config", "/etc/semaphore/semaphore_config.json"]

FROM ubuntu:14.04
MAINTAINER Naftuli Kay <me@naftuli.wtf>
# with credits upstream: https://hub.docker.com/r/geerlingguy/docker-ubuntu1404-ansible/

COPY bin/policy-rc.d /usr/sbin/policy-rc.d

# install system dependencies
RUN apt-get update >/dev/null \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    software-properties-common less >/dev/null \
  && rm -Rf /var/lib/apt/lists/* \
  && apt-get clean >/dev/null

# install ansible
RUN apt-add-repository -y ppa:ansible/ansible >/dev/null \
  && apt-get update >/dev/null \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ansible >/dev/null \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean >/dev/null

# install our wait-for-boot script
COPY bin/wait-for-boot /usr/bin/wait-for-boot

# Install Ansible inventory file
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# workaround for pleaserun tool that Logstash uses
RUN rm -rf /sbin/initctl \
  && ln -s /sbin/initctl.distrib /sbin/initctl

ENTRYPOINT ["/sbin/init"]

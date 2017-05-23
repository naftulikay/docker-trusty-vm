FROM ubuntu:14.04
MAINTAINER Naftuli Kay <me@naftuli.wtf>
# with credits upstream: https://hub.docker.com/r/geerlingguy/docker-ubuntu1404-ansible/

# install system dependencies
RUN apt-get update >/dev/null \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends software-properties-common >/dev/null \
  && rm -Rf /var/lib/apt/lists/* \
  && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
  && apt-get clean >/dev/null

# install ansible
RUN apt-add-repository -y ppa:ansible/ansible >/dev/null \
  && apt-get update >/dev/null \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ansible >/dev/null \
  && rm -rf /var/lib/apt/lists/* \
  && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
  && apt-get clean >/dev/null

# Install Ansible inventory file
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# workaround for pleaserun tool that Logstash uses
RUN rm -rf /sbin/initctl \
  && ln -s /sbin/initctl.distrib /sbin/initctl

ENTRYPOINT ["/sbin/init"]

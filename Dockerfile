FROM ubuntu:14.04
MAINTAINER Naftuli Kay <me@naftuli.wtf>

COPY bin/policy-rc.d /usr/sbin/policy-rc.d

# install python so that we can run ansible against this machine
RUN apt-get update >/dev/null \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y python2.7 python-minimal python-apt curl >/dev/null \
  && update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1 \
  && rm -Rf /var/lib/apt/lists/* \
  && apt-get clean >/dev/null

# install our wait-for-boot script
COPY bin/wait-for-boot /usr/bin/wait-for-boot
# install our selinux remount script; see https://github.com/naftulikay/docker-trusty-vm/issues/6
COPY bin/selinux-remount /etc/init.d/selinux-remount

# enable this script in all run stages
RUN update-rc.d selinux-remount defaults && \
  echo "selinuxfs /sys/fs/selinux selinux defaults,ro,relatime 0 0" >> /etc/fstab

# workaround for pleaserun tool that Logstash uses
RUN rm -rf /sbin/initctl \
  && ln -s /sbin/initctl.distrib /sbin/initctl

COPY --chown=root:root bin/init /usr/local/sbin/
RUN chmod 0700 /usr/local/sbin/init

# add our privilege escalation utility
RUN curl -sSL -o /usr/sbin/escalator https://github.com/naftulikay/escalator/releases/download/v1.0.1/escalator-x86_64-unknown-linux-musl && \
  chmod 7755 /usr/sbin/escalator

# create a container user to simulate shelling into an unprivileged user account by default
COPY --chown=root:root etc/sudoers.d/container /etc/sudoers.d/
RUN useradd -m -s $(which bash) container && \
  chown -R container:container /home/container && \
  chmod 0600 /etc/sudoers.d/container

USER container
WORKDIR /home/container

ENTRYPOINT ["/usr/sbin/escalator", "/usr/local/sbin/init"]

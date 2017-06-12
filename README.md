# docker-trusty-vm [![Build Status][svg-travis]][travis] [![Docker Build][svg-docker]][docker]

A lightweight Ubuntu 14.04 Trusty VM in Docker. [Based on `geerlingguy/docker-ubuntu1404-ansible`][upstream], do read
the author's [excellent post][post] about testing Ansible across multiple operating systems.

Published to the Docker Hub as `naftulikay/trusty-vm`.

### Running:

Ubuntu 14.04 requires no special privileges to run, as opposed some of the systemd containers:

```
docker run --detach naftulikay/trusty-vm:latest
```

The container ID will be emitted by Docker and this can be used to execute commands in the Docker container/"VM".

### Testing Ansible Roles

To test Ansible roles, pass something of the following to mount your role and execute your tests against it:

```
--volume=$(pwd):/etc/ansible/roles/$ROLE_NAME:ro
```

When starting the container, a container ID is emitted; this can be saved and used to execute commands within the Docker
"VM":

```
docker exec --tty $CONTAINER_ID env TERM=xterm ansible --version
docker exec --tty $CONTAINER_ID env TERM=xterm ansible-playbook /path/to/ansible/playbook.yml --syntax-check
```

## Contracts

This container **must** do the following:

#### Services

 - :ballot_box_with_check: enable services to be started via the init manager using `service $x start`.

 [docker]: https://hub.docker.com/r/naftulikay/trusty-vm/
 [svg-docker]: https://img.shields.io/docker/automated/naftulikay/trusty-vm.svg?maxAge=2592000
 [travis]: https://travis-ci.org/naftulikay/docker-trusty-vm
 [svg-travis]: https://travis-ci.org/naftulikay/docker-trusty-vm.svg?branch=develop
 [post]: https://www.jeffgeerling.com/blog/2016/how-i-test-ansible-configuration-on-7-different-oses-docker
 [upstream]: https://hub.docker.com/r/geerlingguy/docker-ubuntu1404-ansible/

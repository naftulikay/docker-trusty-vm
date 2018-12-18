# docker-trusty-vm [![Build Status][travis.svg]][travis] [![Docker Build][docker.svg]][docker]

A lightweight Ubuntu 14.04 Trusty VM in Docker, primarily used for integration testing of Ansible roles.

## Usage

The image and container can be built and started like so:

```
$ docker build -t naftulikay/trusty-vm:latest
$ docker run -d --name trusty naftulikay/trusty-vm:latest
$ docker exec -it trusty wait-for-boot
```

View [`docker-compose.yml`](./docker-compose.yml) for a working reference on how to build and run the image/container.

## License

Licensed at your discretion under either:

 - [MIT License](./LICENSE-MIT)
 - [Apache License, Version 2.0](./LICENSE-APACHE)

 [docker]: https://hub.docker.com/r/naftulikay/trusty-vm/
 [docker.svg]: https://img.shields.io/docker/automated/naftulikay/trusty-vm.svg?maxAge=2592000
 [travis]: https://travis-ci.org/naftulikay/docker-trusty-vm
 [travis.svg]: https://travis-ci.org/naftulikay/docker-trusty-vm.svg?branch=master

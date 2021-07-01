# docker-weechat

[![Drone (cloud)](https://img.shields.io/drone/build/jee-r/docker-weechat?&style=flat-square)](https://cloud.drone.io/jee-r/docker-weechat)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/j33r/weechat?style=flat-square)](https://microbadger.com/images/j33r/weechat)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/j33r/weechat?style=flat-square)](https://microbadger.com/images/j33r/weechat)
[![Docker Pulls](https://img.shields.io/docker/pulls/j33r/weechat?style=flat-square)](https://hub.docker.com/r/j33r/weechat)
[![DockerHub](https://img.shields.io/badge/Dockerhub-j33r/weechat-%232496ED?logo=docker&style=flat-square)](https://hub.docker.com/r/j33r/weechat)

A docker image for [weechat](https://weechat.org) ![weechat logo](https://weechat.org/media/images/favicon.png)

# Supported tags

| Tags | Size | Layers |
|-|-|-|
| `latest`, `stable` | ![](https://img.shields.io/docker/image-size/j33r/weechat/latest?style=flat-square) | ![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/j33r/weechat/latest?style=flat-square) |
| `dev` | ![](https://img.shields.io/docker/image-size/j33r/weechat/dev?style=flat-square) | ![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/j33r/weechat/dev?style=flat-square) |

# What is weechat ?

From [weechat.io](https://weechat.org):

> Full-featured IRC plugin: multi-servers, proxy support, IPv6, SASL authentication, nicklist, DCC, and many other features. 

- Source Code : https://github.com/weechat/weechat
- Documentation : https://weechat.org/doc/
- Official Website : https://weechat.org

# How to use these images

All the lines commented in the examples below should be adapted to your environment. 

Note: `--user $(id -u):$(id -g)` should work out of the box on linux systems. If your docker host run on windows or if you want specify an other user id and group id just replace with the appropriates values.

## With Docker

```bash
docker run \
    --detach \
    --interactive \
    --name weechat \
    --user $(id -u):$(id -g) \
    --volume /etc/localtime:/etc/localtime:ro \
    #--volume ./config:/config \
    --env TZ=Europe/Paris \
    #--publish 8000:8000 \
    #--publish 8001:8001 \
    j33r/weechat:latest
```

## With Docker Compose

[`docker-compose`](https://docs.docker.com/compose/) can help with defining the `docker run` config in a repeatable way rather than ensuring you always pass the same CLI arguments.

Here's an example `docker-compose.yml` config:

```yaml
version: '3'

services:
  weechat:
    image: j33r/weechat:latest
    container_name: weechat
    restart: unless-stopped
    user: $(id -u):$(id -g)
    #ports:
    #  - 8000:8000
    #  - 8002:8002
    environment:
      - TZ=Europe/Paris
    volumes:
      #- ./config:/config
      - /etc/localtime:/etc/localtime:ro
```

## Volume mounts

Due to the ephemeral nature of Docker containers these images provide a number of optional volume mounts to persist data outside of the container:

- `/config`: The weechat config directory containing `weechat.conf`, scripts, logs and all stuff to customize your weechat instance.
- `/etc/localtime`: This directory is for have the same time as host in the container.

You should create directory before run the container otherwise directories are created by the docker deamon and owned by the root user

## Environment variables

- `HOME`: set home diretory for user in the container (default: `/config`).
- `TERM`: set colors in termnal (default: `screen-256color`).
- `LANG`: set locale (default: `C.UTF-8`).
- `TZ`: To change the timezone of the container set the `TZ` environment variable. The full list of available options can be found on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

## Ports

- `8000`: Non-ssl port for relay (change it if necessary).
- `8002`: Ssl port for relay (change it if necessary).

# License

This project is under the [GNU Generic Public License v3](/LICENSE) to allow free use while ensuring it stays open.

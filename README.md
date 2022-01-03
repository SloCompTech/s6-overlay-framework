# Docker image s6overlay

This is **base image** with [s6 overlay (supervisor utils)](https://github.com/just-containers/s6-overlay) already setup. Directory structure is also setup.

## Project structure

```
root # Files copied to image started from root
  etc
    cont-finish.d # See s6-overlay
    cont-init.d # See s6-overlay
    fix-attrs.d # See s6-overlay
    service.d # See s6-overlay
Dockerfile # Image configuration
```

## Directories

Image has prepared directories:

- `/app` for **application**
- `/config` for **configuration**
- `/data` for **application data**
- `/defaults` for **default configuration** which is copied to `/config` if directory is empty
- `/log` for **logging** (often you need separated directory for logs (because you don't want to write to eg. SD card ...))

## Parameters

|**Parameter**|**Function**|
|:-----------:|:-----------|
|`-e CONTAINER_GROUP='abc'`|Set non-root user group name in container|
|`-e CONTAINER_USER='abc'`|Set non-root user used in container (already set in example Dockerfile)|
|`-e NO_DEFAULT_CONFIG=true`|Skip setting up default config|
|`-e PUID=1000`|for UserID - see below for explanation|
|`-e PGID=1000`|for GroupID - see below for explanation|
|`-e TZ=Europe/London`|Specify a timezone|
|`-v /config`|All the config files reside here.|
|`-v /log`|All the log files reside here.|

## Environment variables

|**Variable name**|**Function**|
|:---------------:|:----------:|
|`CONTAINER_USER`|User used to run in less priviledged mode (owner of prepared directories).|
|`CONTAINER_VARS_FILE`|File where base image container variables are stored, load it with `source $CONTAINER_VARS_FILE` at the **top** of your scripts (**\*** - variables that depend on this)|
|`DOCKER_CONTAINER`|Always `true`|
|`RUNCMD`|Put it before every bash command to make sure command is run as container user (generates `sudo -u PID -g GID -E` command) **\***|

## Building locally

``` bash
# Build image
sudo docker build -t IMGNAME .

# Run image
sudo docker run --rm -it IMGNAME bash
```

## Issues

Submit issue [here](https://github.com/SloCompTech/s6-overlay-framework/issues).  

## Documentation

- [Base image from LSIO](https://github.com/linuxserver/docker-baseimage-alpine/blob/master/Dockerfile.aarch64)
- [s6-overlay](https://github.com/just-containers/s6-overlay)

## Versions

- *1.0.0* - First version
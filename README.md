# Docker image s6overlay

This is **template** with [s6 overlay (supervisor utils)](https://github.com/just-containers/s6-overlay) and framework already setup.

Simply start with `Dockerfile.example`.

## Project structure

```
root # Files copied to image started from root
  etc
    cont-finish.d # Finish scripts: See s6-overlay
    cont-init.d # Init scripts: See s6-overlay
    fix-attrs.d # See s6-overlay
    service.d # Service scripts: See s6-overlay
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
|`-e CONTAINER_GROUP='abc'`|Set non-root user group name in container (already set in example Dockerfile)|
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
|`DOCKER_CONTAINER`|Always `true`|

## Non-root user

By default script generates non-root user **abc** and group **abc**. If base image already has user created (eg. node image has node user), then set *CONTAINER_GROUP* and *CONTAINER_USER* so new user won't be created, but existing will be used.

To run programs as non-root user use [s6-overlay](https://github.com/just-containers/s6-overlay#dropping-privileges) or [gosu](https://github.com/tianon/gosu).
## Creating service

Create `run` file in `/etc/services.d/myapp` as explained [here](https://github.com/just-containers/s6-overlay#writing-a-service-script).

Example service script:

``` bash
#!/usr/bin/with-contenv sh

exec s6-setuidgid $CONTAINER_USER myservice
```

Note: Make sure `run` file is executable.

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
- [Gosu](https://github.com/tianon/gosu)
- [s6-overlay](https://github.com/just-containers/s6-overlay)

## Versions

- *1.0.0* - First version

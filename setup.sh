#!/bin/sh
#
# Docker image framework setup
#

set -e

# Defaults (DO NOT CHANGE, use Dockerfile env vars)
DEFAULT_OVERLAY_VERSION='v2.2.0.3'
DEFAULT_ARCH='amd64'
DEFAULT_CONTAINER_GROUP='abc'
DEFAULT_CONTAINER_GROUP_GID=1000
DEFAULT_CONTAINER_USER='abc'
DEFAULT_CONTAINER_USER_UID=1000
DEFAULT_GOSU_VERSION='1.14'

# Variables (settings)
OVERLAY_VERSION="${OVERLAY_VERSION:-$DEFAULT_OVERLAY_VERSION}"
ARCH="${ARCH:-$DEFAULT_ARCH}" # TODO: Try to determin arch from Docker cross build ????
CONTAINER_GROUP="${CONTAINER_GROUP:-$DEFAULT_CONTAINER_GROUP}"
CONTAINER_GROUP_GID=${CONTAINER_GROUP_GID:-$DEFAULT_CONTAINER_GROUP_GID}
CONTAINER_USER="${CONTAINER_USER:-$DEFAULT_CONTAINER_USER}"
CONTAINER_USER_UID=${CONTAINER_USER_UID:-$DEFAULT_CONTAINER_USER_UID}
GOSU_VERSION="${GOSU_VERSION:-$DEFAULT_GOSU_VERSION}"

echo 'Setting up Docker image framework ...'

#
# Install packages
# @see https://github.com/tianon/gosu/blob/master/INSTALL.md
#
echo 'Installing packages...'
if [ -n "$(which apk)" ]; then
  # Alpine
  echo 'Installing packages using apk'
  apk add --no-cache \
    bash \
    bind-tools \
    ca-certificates \
    coreutils \
    curl \
    iputils \
    nano \
    shadow \
    sudo \
    tar \
    tzdata \
    unzip
else
  # Debian based
  echo 'Installing packages using apt'
  apt update
	apt install -y \
    bash \
    ca-certificates \
    coreutils \
    curl \
    dnsutils \
    iputils-ping \
    nano \
    sudo \
    tar \
    tzdata \
    unzip
	apt clean
  rm -rf /var/lib/apt/lists/*
fi
echo 'Packages installed'
echo 'Installing gosu...'
curl -s -o /bin/gosu -L "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${ARCH}"
echo 'Gosu installed'

#
# Create directory structure
# root
# - app
# - config
# - data
# - defaults
# - log
#
echo 'Creating directory structure ...'
mkdir -p /app /config /data /defaults /log
echo 'Directory structure created'

#
# Create user
# @see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
#
echo "Setting up non-root user ${CONTAINER_USER}"
set +e
getent passwd $CONTAINER_USER &>/dev/null
user_exists=$?
set -e
if [ $user_exists -ne 0 ]; then
  # User doesn't exists, create new one
  echo "Non-root user with name ${CONTAINER_USER} doesn't exists yet, setting up"

  # Create user group if it doesn't exists
  set +e
  getent group $CONTAINER_GROUP &>/dev/null
  group_exists=$?
  set -e
  if [ $group_exists -ne 0 ]; then
    echo "Group ${CONTAINER_GROUP} doesn't exists yet, setting up"
    set +e
    getent group $CONTAINER_GROUP_GID &>/dev/null
    group_exists=$?
    set -e
    if [ $group_exists -eq 0 ]; then
      echo "Can't create user group, GID already taken"
      exit 1
    fi

    # Create group
    echo "Creating group ${CONTAINER_GROUP}"
    groupadd \
      --gid=$CONTAINER_GROUP_GID \
      $CONTAINER_GROUP
  fi

  set +e
  getent passwd $CONTAINER_USER_UID &>/dev/null
  user_exists=$?
  set -e
  if [ $user_exists -eq 0 ]; then
    echo "UID ${CONTAINER_USER_UID} already exists"
    exit 1
  fi
  
  echo "Creating user ${CONTAINER_USER}"
  useradd \
    --gid=$CONTAINER_GROUP_GID \
    --home-dir=/config \
    --no-log-init \
    --no-user-group \
    --shell=/bin/false \
    --uid=$CONTAINER_USER_UID \
    $CONTAINER_USER
  echo "User ${CONTAINER_USER} created"
else
  # User already exists, leave it alone
  echo "User ${CONTAINER_USER} already exists"
fi
echo 'User setup done'

#
# Fix directory permissions
#
echo 'Fixing permissions'
chown $CONTAINER_USER:$CONTAINER_USER /app /config /data /defaults /log
echo 'Permissions fixed'

#
#	Install s6-overlay
#	@see https://github.com/just-containers/s6-overlay
#
echo 'Installing s6overlay...'
curl -s -o /tmp/s6-overlay.tar.gz -L "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.gz"
if [ -L '/bin' ] && [ -d '/bin' ]; then
  # /bin is symlink to /usr/bin
  tar xfz /tmp/s6-overlay.tar.gz -C / --exclude='./bin'
  tar xfz /tmp/s6-overlay.tar.gz -C /usr ./bin
else
  tar xfz /tmp/s6-overlay.tar.gz -C / 
fi
rm /tmp/s6-overlay.tar.gz
echo 's6overlay installed'

#
# Install framework scripts
# @see https://github.com/SloCompTech/s6-overlay-framework
# 
echo 'Installing framework scripts...'
curl -o /tmp/repo.zip https://codeload.github.com/SloCompTech/s6-overlay-framework/zip/refs/heads/master # TODO: Add script version
tmp_dir="$(mktemp -d)"
unzip /tmp/repo.zip -d $tmp_dir
cp -r $tmp_dir/s6-overlay-framework-master/root/* /
rm -r $tmp_dir
rm /tmp/repo.zip
echo 'Framework scripts installed'

echo 'Docker image framework setup done'

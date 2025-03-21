# Base image
#checkov:skip=CKV_DOCKER_3
#checkov:skip=CKV_DOCKER_7
# hadolint ignore=DL3007
FROM alpine:latest

# installes required packages for our script
# hadolint ignore=DL3018
RUN	apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  jq

# Copies your code file  repository to the filesystem
COPY entrypoint.sh /entrypoint.sh

# change permission to execute the script and
RUN chmod +x /entrypoint.sh

HEALTHCHECK NONE

# file to execute when the docker container starts up
ENTRYPOINT ["/entrypoint.sh"]

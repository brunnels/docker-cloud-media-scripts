####################
# BASE IMAGE
####################
FROM ubuntu:16.04


####################
# INSTALLATIONS
####################
RUN apt-get update && apt-get install -y \
    curl \
    unionfs-fuse \
    bc \
    screen \
    unzip \
    fuse \
    wget

# MongoDB
RUN \
   apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
   echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list && \
   apt-get update && \
   apt-get install -y mongodb-org


####################
# ENVIRONMENTS
####################
# Rclone
ENV BUFFER_SIZE "500M"
ENV MAX_READ_AHEAD "30G"
ENV CHECKERS "16"

ENV RCLONE_CLOUD_ENDPOINT "gd-crypt:"
ENV RCLONE_LOCAL_ENDPOINT "local-crypt:"

# Plexdrive
ENV CHUNK_SIZE "10M"
ENV CLEAR_CHUNK_MAX_SIZE "1000G"
ENV CLEAR_CHUNK_AGE "24h"

ENV MONGO_DATABASE "plexdrive"

# Time format
ENV DATE_FORMAT "+%F@%T"

# Local files removal
ENV REMOVE_LOCAL_FILES_BASED_ON "space"
ENV REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB "2500"
ENV FREEUP_ATLEAST_GB "1000"
ENV REMOVE_LOCAL_FILES_AFTER_DAYS "60"


####################
# SCRIPTS
####################
COPY setup/* /usr/local/bin/

COPY install.sh /
RUN sh /install.sh

COPY scripts/* /usr/local/bin/


####################
# VOLUMES
####################
# Define mountable directories.
VOLUME /data/db /config /cloud-encrypt /cloud-decrypt /local-decrypt /local-media /chunks /log


####################
# WORKING DIRECTORY
####################
WORKDIR /data


####################
# COMMANDS
####################
CMD ["mongod", "/bin/bash -c mount"]
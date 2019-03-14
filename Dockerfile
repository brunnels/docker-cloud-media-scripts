FROM alpine:latest

ENV RCLONE_VERSION="v1.45"
ENV RCLONE_RELEASE="rclone-${RCLONE_VERSION}-linux-amd64"
ENV RCLONE_ZIP="${RCLONE_RELEASE}.zip"
ENV RCLONE_URL="https://github.com/ncw/rclone/releases/download/${RCLONE_VERSION}/${RCLONE_ZIP}"
ENV COPY_BUFFER_SIZE="512M" \
    COPY_CHECKERS=16 \
    DATE_FORMAT="+%Y/%m/%d %T" \
    # if USE_LOGFILES=0 everything goes to docker container log
    USE_LOGFILES=0 \
    PLEX_URL="" \
    PLEX_TOKEN="" \
    # Can have VERBOSE or LOG_LEVEL NOT BOTH.
    # VERBOSE trumps LOG_LEVEL
    RCLONE_VERBOSE=0 \
    RCLONE_LOG_LEVEL="NOTICE" \
    RCLONE_REMOTE_CONTROL=0 \
    RCLONE_LOCAL_ENDPOINT="local-decrypt:" \
    RCLONE_CLOUD_ENDPOINT="direct-decrypt:" \
    RCLONE_CLOUD_OPTIONS="--dir-cache-time=70h" \
    RCLONE_READ_OPTIONS="--allow-other --buffer-size=2048M --dir-cache-time=72h --drive-chunk-size=256M --vfs-read-chunk-size=256M --vfs-read-chunk-size-limit=0 --transfers=10 --rc --tpslimit=5" \
    MERGERFS_OPTIONS="splice_move,atomic_o_trunc,auto_cache,big_writes,default_permissions,direct_io,nonempty,allow_other,sync_read,category.create=ff,category.search=ff,minfreespace=0" \
    RCLONE_PRECACHE=1 \
    REMOVE_LOCAL_FILES_BASED_ON="" \
    REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB="100" \
    FREEUP_ATLEAST_GB=80 \
    REMOVE_LOCAL_FILES_AFTER_DAYS=30 \
    REMOVE_EMPTY_DIR_DEPTH=1 \
    CLOUD_UPLOAD_CRON="5 */1 * * *" \
    RM_DELETE_CRON="50 */1 * * *" \
    CHECKMOUNTS_CRON="*/1 * * * *" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_KEEP_ENV=1 \
    USER_NAME=nobody \
    PUID=1000 \
    PGID=1000 \
    UMASK=000

COPY scripts/* /usr/local/bin/
COPY root /

RUN apk update \
 && apk add --no-cache bash bc ca-certificates coreutils curl findutils fuse openssl procps shadow tzdata unionfs-fuse unzip \
 && sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf \
 && apk add mergerfs --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
 && OVERLAY_VERSION=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') \
 && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" -o /tmp/s6-overlay.tar.gz \
 && tar xfz /tmp/s6-overlay.tar.gz -C / \
 && cd /tmp \
 && curl -fsSL ${RCLONE_URL} -o /tmp/${RCLONE_ZIP} \
 && unzip ${RCLONE_ZIP} \
 && chmod a+x ${RCLONE_RELEASE}/rclone \
 && cp -rf ${RCLONE_RELEASE}/rclone /usr/bin/rclone \
 && rm -rf ${RCLONE_ZIP}\
 && rm -rf ${RCLONE_RELEASE} \
 && apk del \
    curl \
    unzip \
    wget \
 && chmod a+x /usr/local/bin/* \
 && rm -rf /tmp/*

VOLUME /config /read-decrypt /cloud-decrypt /local-decrypt /local-media /log

RUN chmod -R 777 /log

WORKDIR /

ENTRYPOINT ["/init"]

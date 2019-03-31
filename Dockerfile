FROM alpine:latest

ENV RCLONE_VERSION="v1.45"
ENV RCLONE_RELEASE="rclone-${RCLONE_VERSION}-linux-amd64"
ENV RCLONE_ZIP="${RCLONE_RELEASE}.zip"
ENV RCLONE_URL="https://github.com/ncw/rclone/releases/download/${RCLONE_VERSION}/${RCLONE_ZIP}"
ENV COPY_BUFFER_SIZE="512M" \
    COPY_CHECKERS=16 \
    TZ="CST6CDT" \
    DATE_FORMAT="+%Y/%m/%d %T" \
    DEBUG_ENABLED=0 \
    PLEX_URL="" \
    PLEX_TOKEN="" \
    RCLONE_VERBOSE=0 \
    RCLONE_LOG_LEVEL="NOTICE" \
    RCLONE_REMOTE_CONTROL=0 \
    LOCAL_DECRYPT_ENDPOINT="local-decrypt:" \
    CLOUD_DECRYPT_ENDPOINT="direct-decrypt:" \
    CLOUD_DECRYPT_OPTIONS="--dir-cache-time=70h" \
    READ_DECRYPT_OPTIONS="--allow-other --buffer-size=2048M --dir-cache-time=72h --drive-chunk-size=256M --vfs-read-chunk-size=256M --vfs-read-chunk-size-limit=0 --transfers=10 --rc --tpslimit=5" \
    MERGERFS_OPTIONS="splice_move,atomic_o_trunc,auto_cache,big_writes,default_permissions,direct_io,nonempty,allow_other,sync_read,category.create=ff,category.search=ff,minfreespace=0" \
    RCLONE_PRECACHE=1 \
    REMOVE_LOCAL_FILES_BASED_ON="" \
    REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB="100" \
    FREEUP_ATLEAST_GB=80 \
    REMOVE_LOCAL_FILES_AFTER_DAYS=30 \
    REMOVE_EMPTY_DIR_DEPTH=1 \
    CLOUD_UPLOAD_CRON="10 */1 * * *" \
    RM_DELETE_CRON="50 */1 * * *" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_KEEP_ENV=1 \
    USER_NAME=nobody \
    PUID=100 \
    PGID=99 \
    UMASK=000

RUN apk update \
 && apk add --no-cache bash bc ca-certificates coreutils curl findutils fuse openssl procps shadow tzdata unzip attr \
 && sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf \
 && apk add mergerfs --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
 && OVERLAY_VERSION=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') \
 && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" -o /tmp/s6-overlay.tar.gz \
 && tar -C / -xzf /tmp/s6-overlay.tar.gz \
 && cd /tmp \
 && curl -fsSL ${RCLONE_URL} -o /tmp/${RCLONE_ZIP} \
 && unzip ${RCLONE_ZIP} \
 && chmod a+x ${RCLONE_RELEASE}/rclone \
 && cp -rf ${RCLONE_RELEASE}/rclone /usr/bin/rclone \
 && rm -rf ${RCLONE_ZIP}\
 && rm -rf ${RCLONE_RELEASE} \
 && apk del unzip \
 && rm -rf /tmp/*

COPY root /
RUN chmod a+x /usr/local/bin/* \
 && chmod a+x -R /etc/cont-init.d \
 && chmod a+x -R /etc/services.d

VOLUME /config /read-decrypt /cloud-decrypt /local-decrypt /local-media

EXPOSE 5572

WORKDIR /

ENTRYPOINT ["/init"]

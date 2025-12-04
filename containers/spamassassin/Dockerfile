ARG DEBIAN_VERSION=13-slim
FROM debian:${DEBIAN_VERSION} AS base

ARG PERL_DEPENDENCIES="perl libdigest-sha-perl libhtml-parser-perl libnet-dns-perl libnetaddr-ip-perl libencode-detect-perl libmime-base64-perl libnet-libidn-perl libemail-address-xs-perl libmail-dkim-perl libmail-spf-perl libmail-dmarc-perl libio-socket-ip-perl librazor2-perl libio-socket-inet6-perl libio-string-perl libbsd-resource-perl libarchive-zip-perl libnet-patricia-perl libmaxmind-db-reader-xs-perl libip-geolocation-mmdb-perl"

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends ca-certificates wget re2c libssl3 gpg ${PERL_DEPENDENCIES}; \
    rm -rf /var/lib/apt/lists/*

FROM base AS build

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends subversion make gcc build-essential libssl-dev; \
    rm -rf /var/lib/apt/lists/*

ARG SPAMASSASSIN_REPO_URL=https://svn.apache.org/repos/asf/spamassassin
ARG SPAMASSASSIN_TAG=spamassassin_release_4_0_2

RUN set -eux; \
    mkdir /build; \
    mkdir /install_root; \
    chown nobody:nogroup /build; \
    chown nobody:nogroup /install_root

USER nobody

WORKDIR /build

RUN set -eux; \
    svn checkout ${SPAMASSASSIN_REPO_URL}/tags/${SPAMASSASSIN_TAG} /build; \
    perl Makefile.PL DESTDIR=/install_root CONFDIR=/etc/spamassassin ENABLE_SSL=yes; \
    make; \
    make install
    

FROM base

COPY --link --from=build /install_root /
COPY entrypoint.sh /entrypoint.sh

ENV PORT=30783
ENV ENABLE_SSL="no"
ENV SSL_PORT=""
ENV USER_CONFIG_BASE_DIR=/home
ENV SPAMD_PID_FILE=/run/spamd.pid

RUN set -eux; \
    mkdir -p /var/lib/spamassassin; \
    touch ${SPAMD_PID_FILE}; \
    chown nobody:root ${USER_CONFIG_BASE_DIR}; \
    chown nobody:root /var/lib/spamassassin; \
    chown nobody:root ${SPAMD_PID_FILE}; \
    chmod g=u ${USER_CONFIG_BASE_DIR}; \
    chmod g=u /var/lib/spamassassin; \
    chmod g=u ${SPAMD_PID_FILE}; \
    chmod a+x /entrypoint.sh

USER nobody

EXPOSE ${PORT}

VOLUME /var/lib/spamassassin
VOLUME ${USER_CONFIG_BASE_DIR}

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "spamd", "$OPTIONS" ]

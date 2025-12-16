ARG DEBIAN_VERSION=13-slim
FROM debian:${DEBIAN_VERSION} AS spamassassin-base

ENV LC_ALL=C.UTF8
ARG DEBIAN_FRONTEND=noninteractive

ARG PERL_DEPENDENCIES="perl libdigest-sha-perl libhtml-parser-perl libnet-dns-perl libnetaddr-ip-perl libencode-detect-perl libmime-base64-perl libnet-libidn-perl libemail-address-xs-perl libmail-dkim-perl libmail-spf-perl libmail-dmarc-perl libio-socket-ip-perl librazor2-perl libio-socket-inet6-perl libio-string-perl libbsd-resource-perl libarchive-zip-perl libnet-patricia-perl libmaxmind-db-reader-xs-perl libip-geolocation-mmdb-perl"

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends ca-certificates wget libssl3 ${PERL_DEPENDENCIES}; \
    rm -rf /var/lib/apt/lists/*

ENV USER_PREFS_DIR=/user-prefs
ENV RULES_DIR=/var/lib/spamassassin

RUN set -eux; \
    mkdir -p ${USER_PREFS_DIR}; \
    mkdir -p ${RULES_DIR}; \
    chown nobody:root ${USER_PREFS_DIR}; \
    chown nobody:root ${RULES_DIR}; \
    chmod g=u ${USER_PREFS_DIR}; \
    chmod g=u ${RULES_DIR}

VOLUME ${RULES_DIR}
VOLUME ${USER_PREFS_DIR}

FROM spamassassin-base AS spamassassin-build

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends subversion make gcc build-essential libssl-dev; \
    rm -rf /var/lib/apt/lists/*

ARG SPAMASSASSIN_REPO_URL=https://svn.apache.org/repos/asf/spamassassin
ARG SPAMASSASSIN_VERSION=spamassassin_release_4_0_2

RUN set -eux; \
    mkdir /build; \
    mkdir /install_root; \
    chown nobody:nogroup /build; \
    chown nobody:root /install_root

USER nobody

WORKDIR /build

RUN set -eux; \
    svn checkout ${SPAMASSASSIN_REPO_URL}/tags/${SPAMASSASSIN_VERSION} /build; \
    perl Makefile.PL PREFIX=/usr DESTDIR=/install_root CONFDIR=/etc/spamassassin ENABLE_SSL=yes; \
    make; \
    make install

FROM spamassassin-base AS spamassassin

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=spamassassin-build --exclude=/install_root/usr/bin/sa-compile /install_root /
COPY entrypoint.sh /entrypoint.sh

ENV PORT=30783
ENV ENABLE_SSL="no"
ENV SSL_PORT=""
ENV SPAMD_PID_FILE=/run/spamd.pid
ENV SPAMD_OPTIONS=""

RUN set -eux; \
    touch ${SPAMD_PID_FILE}; \
    chown nobody:root ${SPAMD_PID_FILE}; \
    chmod g=u ${SPAMD_PID_FILE}; \
    chmod a+x /entrypoint.sh

USER nobody

EXPOSE ${PORT}

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "spamd", "${SPAMD_OPTIONS}" ]

FROM spamassassin-base AS sa-maintenance

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends re2c make gcc libperl-dev gpg; \
    rm -rf /var/lib/apt/lists/*

COPY --from=spamassassin-build --exclude=/install_root/usr/bin/spamd /install_root /
COPY spamassassin-maint.sh /spamassassin-maint.sh

RUN set -eux; \
    chmod a+x /spamassassin-maint.sh

USER nobody

CMD [ "/spamassassin-maint.sh" ]
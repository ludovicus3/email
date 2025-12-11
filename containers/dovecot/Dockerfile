ARG DEBIAN_VERSION=13-slim
FROM debian:${DEBIAN_VERSION} AS dovecot-build

ARG DOVECOT_REPO_URL=https://github.com/dovecot/core
ARG DOVECOT_VERSION=2.4.2

ARG BUILD_DEPENDENCIES="libssl-dev libcap-dev libbz2-dev liblz4-dev libldap2-dev liblua5.3-dev libsqlite3-dev libdb-dev libpq-dev libsasl2-dev libicu-dev libkrb5-dev default-libmysqlclient-dev libzstd-dev libexpat-dev libxapian-dev libstemmer-dev libsodium-dev libexttextcat-dev"

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends git build-essential ca-certificates make autoconf automake libtool gettext pkg-config bison flex devscripts wget ssl-cert ${BUILD_DEPENDENCIES}; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir /build; \
    mkdir /dovecot; \
    chown nobody /build; \
    chown nobody /dovecot

USER nobody

WORKDIR /build/core

RUN set -eux; \
    git clone --single-branch --branch ${DOVECOT_VERSION} ${DOVECOT_REPO_URL} .; \
    ./autogen.sh; \
    ./configure \
        --with-ldap=plugin \
        --with-sql=plugin \
        --with-lua=plugin \
        --with-pgsql \
        --with-mysql \
        --with-sqlite \
        --with-gssapi=plugin \
        --with-solr \
        --with-flatcurve \
        --with-ioloop=best \
        --with-icu \
        --with-lz4 \
        --with-sodium \
        --with-zstd \
        --with-bzlib \
        --with-stemmer \
        --with-textcat \
        --with-libcap \
        --enable-experimental-mail-utf8 \
        --with-retpoline=thunk-inline \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/run/dovecot/state \
        --with-statedir=/run/dovecot/state \
        --docdir=/usr/share/doc/dovecot-core \
        --with-moduledir=\${libdir}/dovecot/modules \
        --with-rundir=/run/dovecot \
        --disable-rpath \
        --disable-static; \
    make

USER root

RUN set -eux; \
    make install-strip DESTDIR=/dovecot; \
    mkdir -p /dovecot/etc/dovecot/ssl; \
    make-ssl-cert generate-default-snakeoil; \
    mv /etc/ssl/certs/ssl-cert-snakeoil.pem /dovecot/etc/dovecot/ssl/tls.crt; \
    mv /etc/ssl/private/ssl-cert-snakeoil.key /dovecot/etc/dovecot/ssl/tls.key

USER nobody

WORKDIR /build/pigeonhole

ARG PIGEONHOLE_REPO_URL=https://github.com/dovecot/pigeonhole
ARG PIGEONHOLE_VERSION=2.4.2

RUN set -eux; \
    git clone --single-branch --branch ${PIGEONHOLE_VERSION} ${PIGEONHOLE_REPO_URL} .; \
    ./autogen.sh; \
    ./configure \
        --with-dovecot=/build/core \
        --with-ldap=plugin \
        --prefix=/usr \
        --sysconfdir=/etc \
        --with-rundir=/run/dovecot \
        --disable-rpath \
        --disable-static \
        --with-retpoline=thunk-inline \
        --with-unfinished-features; \
    make

USER root

RUN set -eux; \
    make install-strip DESTDIR=/dovecot

FROM quay.io/ludovicus/kubemail:spamassassin-v4.0.2 AS spamassassin

FROM debian:${DEBIAN_VERSION} AS dovecot

ARG DEPENDENCIES="libssl3 libcap2 libbz2-1.0 liblz4-1 libldap2 liblua5.3-0 libsqlite3-0 libpq5 libsasl2-2 libicu76 libkrb5-3 libmariadb3 libzstd1 libexpat1 libxapian30 libstemmer0d libsodium23 libexttextcat-2.0-0"
ARG DOVECOT_UID=1000

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends tini ${DEPENDENCIES}; \
    rm -rf /var/lib/apt/lists/*

COPY --from=spamassassin /usr/bin/spamc /usr/bin/spamc
COPY --from=dovecot-build /dovecot /

RUN set -eux; \
    mkdir -p /etc/dovecot/sieve/default \
        /run/dovecot \
        /var/mail

COPY sieve /etc/dovecot/sieve
COPY scripts /usr/lib/dovecot/sieve
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY conf.d /etc/dovecot/conf.d

RUN set -eux; \
    useradd -u $DOVECOT_UID -g root -d /var/mail -s /bin/sh dovecot; \
    chown -R dovecot:root \
        /etc/dovecot \
        /run/dovecot \
        /var/mail; \
    chmod -R g=u \
        /etc/dovecot \
        /run/dovecot \
        /var/mail; \
    chmod a+x /usr/lib/dovecot/sieve/*.sh

USER dovecot

ENV DOVEADM_PASSWORD
ENV SPAMASSASSIN_HOST
ENV SPAMASSASSIN_PORT

# doveadm
EXPOSE 8443
# stats
EXPOSE 9090
# lmtp
EXPOSE 30024
# imap
EXPOSE 30143
# imaps
EXPOSE 30993
# pop3
EXPOSE 30110
# pop3s
EXPOSE 30995
# submission
EXPOSE 30587
# submissions
EXPOSE 30465
# sieve
EXPOSE 34190
VOLUME /var/mail

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/usr/sbin/dovecot", "-F" ]

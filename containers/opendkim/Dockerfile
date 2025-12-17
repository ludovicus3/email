ARG DEBIAN_VERSION=13-slim
FROM debian:${DEBIAN_VERSION} AS opendkim-build

ARG DEBIAN_FRONTEND=noninteractive

ENV LC_ALL=C.UTF-8

ARG BUILD_DEPENDENCIES="libssl-dev libmilter-dev libmemcached-dev libunbound-dev liblua5.1-dev libopendbx-dev libldap-dev lua-cyrussasl-dev libdb-dev"

RUN set -eux; \
    apt-get update; \
    apt-get --yes --no-install-recommends install ca-certificates git make build-essential autoconf automake libtool m4 pkg-config gcc-13 g++-13 ${BUILD_DEPENDENCIES}; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir /build; \
    mkdir /install_root; \
    chown nobody:nogroup /build

WORKDIR /build

USER nobody

ARG OPENDKIM_REPO_URL=https://github.com/trusteddomainproject/OpenDKIM.git
ARG OPENDKIM_BRANCH=rel-opendkim-2-11-0-Beta2

RUN set -eux; \
    git clone --single-branch --branch ${OPENDKIM_BRANCH} ${OPENDKIM_REPO_URL} .

ENV CC=gcc-13
ENV CXX=g++-13

RUN set -eux; \
    autoreconf -fi; \
    ./configure \
      --disable-live-testing \
      --disable-static \
      --prefix=/usr \
      --sysconfdir=/etc \
      --enable-vbr \
      --enable-rbl \
      --enable-atps \
      --enable-stats \
      --enable-replace_rules \
      --enable-query_cache \
      --enable-sender_macro \
      --with-libmemcached \
      --with-openldap \
      --with-db \
      --with-sql-backend \
      --with-sasl \
      --with-lua \
      --with-unbound \
      --with-odbx; \
    make

USER root

RUN set -eux; \
    make install DESTDIR=/install_root

FROM debian:${DEBIAN_VERSION} AS opendkim

ARG DEPENDENCIES="libssl3 libmilter1.0.1 libmemcached11 libunbound8 liblua5.1-0 libopendbx1 libldap2 libdb5.3 lua-cyrussasl"

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends stdsyslog dns-root-data ${DEPENDENCIES}; \
    rm -rf /var/lib/apt/lists/*

COPY --from=opendkim-build /install_root /
COPY opendkim.conf /etc/opendkim.conf
COPY entrypoint.sh /entrypoint.sh

RUN set -eux; \
    mkdir -p /run/opendkim /etc/opendkim; \
    touch /etc/opendkim/trusted.hosts /etc/opendkim/keys.table /etc/opendkim/signing.table; \
    chown -R nobody:root /etc/opendkim /run/opendkim; \
    chmod -R g=u /etc/opendkim /run/opendkim; \
    chmod a+x /entrypoint.sh

USER nobody
 
EXPOSE 8891

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/opendkim" ]

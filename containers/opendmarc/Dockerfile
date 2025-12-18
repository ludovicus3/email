ARG DEBIAN_VERSION=13-slim
FROM debian:${DEBIAN_VERSION} AS opendmarc-build

ARG DEBIAN_FRONTEND=noninteractive

ENV LC_ALL=C.UTF-8

ARG BUILD_DEPENDENCIES="libmilter-dev"

RUN set -eux; \
    apt-get update; \
    apt-get upgrade --yes --no-install-recommends; \
    apt-get install --yes --no-install-recommends ca-certificates git make build-essential autoconf automake libtool m4 pkg-config ${BUILD_DEPENDENCIES}; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir /build; \
    mkdir /install_root; \
    chown nobody:nogroup /build

WORKDIR /build

USER nobody

ARG OPENDMARC_REPO_URL=https://github.com/trusteddomainproject/OpenDMARC.git
ARG OPENDMARC_BRANCH=rel-opendmarc-1-4-2

RUN set -eux; \
    git clone --single-branch --branch ${OPENDMARC_BRANCH} ${OPENDMARC_REPO_URL} .

RUN set -eux; \
    autoreconf -fi; \
    ./configure \
      --disable-static \
      --prefix=/usr \
      --sysconfdir=/etc \
      --with-spf \
      --with-sql-backend; \
    make

USER root

RUN set -eux; \
    make install DESTDIR=/install_root

FROM debian:${DEBIAN_VERSION} AS opendmarc

ARG DEPENDENCIES="libmilter1.0.1"

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends stdsyslog ${DEPENDENCIES}; \
    rm -rf /var/lib/apt/lists/*

COPY --from=opendmarc-build /install_root /
COPY opendmarc.conf /etc/opendmarc.conf
COPY entrypoint.sh /entrypoint.sh

RUN set -eux; \
    mkdir -p /run/opendmarc /etc/opendmarc; \
    touch /etc/opendmarc/ignore.hosts; \
    chown -R nobody:root /etc/opendmarc /run/opendmarc; \
    chmod -R g=u /etc/opendmarc /run/opendmarc; \
    chmod a+x /entrypoint.sh

USER nobody
 
EXPOSE 8891

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/opendmarc" ]

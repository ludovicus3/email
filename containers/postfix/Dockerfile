ARG DEBIAN_VERSION=13-slim 
FROM debian:${DEBIAN_VERSION} AS build

ARG POSTFIX_REPO_URL=https://github.com/vdukhovni/postfix.git
ARG POSTFIX_VERSION=v3.10.5

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends ca-certificates git make m4 build-essential libdb5.3-dev libnsl-dev libicu-dev; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir /build; \
    chown nobody /build

WORKDIR /build
USER nobody

RUN set -eux; \
    git clone --single-branch --branch ${POSTFIX_VERSION} ${POSTFIX_REPO_URL} .

WORKDIR /build/postfix

RUN set -eux; \
    make

USER root

RUN set -eux; \
    mkdir /install; \
    make non-interactive-package install_root=/install

FROM debian:${DEBIAN_VERSION}

ARG POSTFIX_UID=1000
ARG POSTFIX_GID=1000
ARG POSTDROP_GID=1001

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends ca-certificates libdb5.3 libnsl2 libicu76; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /etc/postfix; \
    mkdir -p /etc/postfix/overrides.d; \
    mkdir -p /etc/postfix/maps.d; \
    mkdir -p /var/spool/postfix; \
    groupadd -g ${POSTFIX_GID} postfix; \
    useradd -u ${POSTFIX_UID} -g postfix -G root -d /var/spool/postfix -s /usr/sbin/nologin postfix; \
    groupadd -g ${POSTDROP_GID} postdrop

COPY --from=build /install /
COPY --chmod=0755 entrypoint.sh /entrypoint.sh
COPY --chmod=0640 master.cf /etc/postfix/master.cf
COPY --chmod=0640 main.cf /etc/postfix/main.cf
COPY --chmod=0640 aliases /etc/postfix/aliases

RUN set -eux; \
    chown postfix /var/spool/postfix/* /var/lib/postfix; \
    chown root /var/spool/postfix/pid; \
    chmod g+s /usr/sbin/postqueue /usr/sbin/postdrop; \
    chgrp postdrop /var/spool/postfix/maildrop /var/spool/postfix/public /usr/sbin/postqueue /usr/sbin/postdrop

EXPOSE 25
EXPOSE 465
EXPOSE 587

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/postfix", "start-fg" ]

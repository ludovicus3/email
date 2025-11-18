FROM debian:13-slim

ENV container=docker \
    LC_ALL=C.UTF-8
ARG OPENDKIM_VERSION=2.11.0~beta2-9.1+b1

RUN apt-get --yes --quiet update; \
    apt-get --yes --quiet install --no-install-recommends \
        opendkim=${OPENDKIM_VERSION} opendkim-tools=${OPENDKIM_VERSION} openssl tini stdsyslog;\
    apt-get clean --yes --quiet; \
    apt-get autoremove --yes --quiet; \
    rm -rf /var/lib/apt/lists/*

COPY opendkim.conf /etc/opendkim.conf
COPY start.sh /start.sh

RUN \
    chmod +x /start.sh; \
    mkdir -p /etc/opendkim/keys; \
    chown -R opendkim:root /etc/opendkim; \
    chown opendkim:root /run/opendkim; \
    chmod gu=rwx /run/opendkim

EXPOSE 8891
USER opendkim

CMD [ "/start.sh" ]

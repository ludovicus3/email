FROM debian:13-slim

ENV container=docker \
    LC_ALL=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
ARG OPENDKIM_VERSION=2.11.0~beta2-9.1+b1

RUN apt-get --yes --quiet update; \
    apt-get --yes --quiet install --no-install-recommends \
        opendkim=${OPENDKIM_VERSION} opendkim-tools=${OPENDKIM_VERSION}; \
    apt-get clean --yes --quiet; \
    apt-get autoremove --yes --quiet; \
    rm -rf /var/lib/apt

COPY opendkim.conf /etc/opendkim.conf

RUN \
    mkdir -p /etc/opendkim/keys; \
    chown -R opendkim:opendkim /etc/opendkim; \
    chmod -R g=o /etc/opendkim

EXPOSE 8891
USER opendkim

CMD [ "/usr/sbin/opendkim" ]

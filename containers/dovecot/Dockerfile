FROM debian:13-slim

ENV LC_ALL=C.UTF-8 \
    TZ=UTC

ARG VMAIL_UID=1000
ARG VMAIL_GID=1000
ARG VMAIL_DIR=/var/mail

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends \
        dovecot-core dovecot-flatcurve dovecot-imapd dovecot-submissiond dovecot-ldap dovecot-sieve dovecot-managedsieved dovecot-pop3d dovecot-lmtpd \
        spamc \
        tini; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    groupadd -g $VMAIL_GID vmail; \
    useradd -u $VMAIL_UID -g vmail -d $VMAIL_DIR -s /bin/sh vmail; \
    passwd -l vmail; \
    mkdir -p $VMAIL_DIR; \
    mkdir -p /etc/dovecot/sieve; \
    mkdir -p /etc/dovecot/services.d; \
    mkdir -p /etc/dovecot/ssl; \
    rm -f /etc/dovecot/conf.d/*; \
    chown vmail:vmail /var/lib/dovecot; \
    chown vmail:vmail $VMAIL_DIR; \
    chmod 0770 /var/lib/dovecot; \
    chmod 0700 $VMAIL_DIR

COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY conf.d/ /etc/dovecot/conf.d
COPY services.d/ /etc/dovecot/services.d
COPY sieve/ /etc/dovecot/sieve
COPY scripts/ /usr/lib/dovecot/sieve

RUN set -eux; \
    chmod +x /usr/lib/dovecot/sieve/*.sh

EXPOSE 30024
EXPOSE 30110
EXPOSE 30143
EXPOSE 30465
EXPOSE 30587
EXPOSE 30993
EXPOSE 30995
EXPOSE 34190
EXPOSE 8443
EXPOSE 9090
USER vmail
VOLUME [ "$VMAIL_DIR" ]
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD  ["/usr/sbin/dovecot", "-F" ]

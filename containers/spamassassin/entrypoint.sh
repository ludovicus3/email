#!/bin/sh

export LISTEN_IP="--listen-ip"

if [ "${ENABLE_SSL}" = "yes" ]; then
  export SSL_OPTIONS="--ssl --server-cert ${SSL_CERT_FILE:-/etc/spamassassin/ssl/tls.crt} --server-key ${SSL_KEY_FILE:-/etc/spamassassin/ssl/tls.key}"
  if [ -n "${SSL_PORT}" ]; then
    export SSL_OPTIONS="${SSL_OPTIONS} --ssl-port=${SSL_PORT}"
  fi
fi

export USER=$(whoami)
if [ -n "${USER_CONFIG_BASE_DIR}" ]; then
  export USER_CONFIG="--username=${USER} --allow-tell --create-prefs --nouser-config --virtual-config-dir=${USER_CONFIG_BASE_DIR}/%d/%l"
fi

if [ -z "${OPTIONS}" ]; then
  export OPTIONS="--syslog-socket=none --pidfile=${SPAMD_PID_FILE} ${LISTEN_IP} --port=${PORT:-30783} --max-children=5 ${SSL_OPTIONS} ${USER_CONFIG}"
fi

exec $@

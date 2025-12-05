#!/bin/sh

if [ "${ENABLE_SSL}" = "yes" ]; then
  export SSL_OPTIONS="--ssl --server-cert ${SSL_CERT_FILE:-/etc/spamassassin/ssl/tls.crt} --server-key ${SSL_KEY_FILE:-/etc/spamassassin/ssl/tls.key}"
  if [ -n "${SSL_PORT}" ] && [ "${PORT}" != "${SSL_PORT}" ]; then
    export SSL_OPTIONS="${SSL_OPTIONS} --ssl-port=${SSL_PORT}"
  fi
fi

export USER=$(whoami)
if [ -n "${USER_PREFS_DIR}" ]; then
  export USER_CONFIG="--username=${USER} --allow-tell --create-prefs --nouser-config --virtual-config-dir=${USER_PREFS_DIR}/%d/%l"
fi

if [ -z "${SPAMD_OPTIONS}" ]; then
  export SPAMD_OPTIONS="--syslog-socket=none --pidfile=${SPAMD_PID_FILE} --listen-ip --port=${PORT:-30783} --max-children=5 ${SSL_OPTIONS} ${USER_CONFIG}"
fi

case $@ in
  spamd)
    exec /usr/local/bin/spamd ${SPAMD_OPTIONS}
    ;;
  sa-update)
    exec /usr/local/bin/sa-update
    ;;
  *)
    exec $@
    ;;
esac

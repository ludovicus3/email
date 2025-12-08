#!/bin/sh

if [ "${ENABLE_SSL}" = "yes" ]; then
  export SSL_OPTIONS="--ssl --server-cert /etc/spamassassin/ssl/tls.crt --server-key /etc/spamassassin/ssl/tls.key"
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

do_maintenance() {
  sa-update
  case $? in
    0)
      # got updates
      sa-compile
      exit 0
      ;;
    1)
      # no updates
      exit 0
      ;;
    2)
      spamassassin -- --debug --lint 2>&1
      exit 1
      ;;
    *)
      echo "sa-update failed for unknown reasons" 1>&2
      exit 1
      ;;
  esac
}

case $@ in
  spamd)
    exec spamd ${SPAMD_OPTIONS}
    ;;
  maintenance)
    do_maintenance
    ;;
  *)
    exec $@
    ;;
esac

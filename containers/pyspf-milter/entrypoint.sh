#!/bin/sh

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USERNAME:-pyspf-milter}:x:$(id -u):0::/run/pyspf-milter:/usr/sbin/nologin" >> /etc/passwd
    echo "${USERNAME:-pyspf-milter}:x:$(id -u):" >> /etc/group
  fi
fi

exec "$@"
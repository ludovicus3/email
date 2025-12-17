#!/bin/sh

set -eux

if [ "$@" = "/usr/sbin/opendkim" ]; then
  exec stdsyslog -f mail -p /run/opendkim/opendkim.pid $@ -f
else
  exec $@
fi

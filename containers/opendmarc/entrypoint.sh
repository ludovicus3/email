#!/bin/sh

set -eux

if [ "$@" = "/usr/sbin/opendmarc" ]; then
  exec stdsyslog -f mail -p /run/opendmarc/opendmarc.pid $@ -f
else
  exec $@
fi

#!/bin/sh

set -eux

if [ "$*" = "opendkim" ]; then
  exec stdsyslog -f mail -p /run/opendkim/opendkim.pid $@
else
  exec $@
fi

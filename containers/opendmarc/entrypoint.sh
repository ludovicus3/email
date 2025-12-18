#!/bin/sh

set -eux

if [ "$*" = "opendmarc" ]; then
  exec stdsyslog -f mail -p /run/opendmarc/opendmarc.pid $@
else
  exec $@
fi

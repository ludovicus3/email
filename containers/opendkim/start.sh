#!/bin/sh

exec stdsyslog -f mail -p /run/opendkim/opendkim.pid /usr/sbin/opendkim -f
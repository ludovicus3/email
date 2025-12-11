#!/bin/sh
exec /usr/bin/spamc --dest ${SPAMASSASSIN_HOST} --port ${SPAMASSASSIN_PORT:-783} --username ${1} --learntype ham
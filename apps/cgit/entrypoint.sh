#!/bin/sh

/usr/bin/spawn-fcgi \
    -u cgit -g cgit \
    -M 664 \
    -s /run/fcgiwrap.sock \
    /usr/bin/fcgiwrap &

/usr/sbin/nginx -g "daemon off;"

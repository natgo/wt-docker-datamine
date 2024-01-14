#!/bin/sh

if [ -e "/data/datamine.lock" ]; then
    rm "/data/datamine.lock"
fi

printenv | grep -v "no_proxy" >> /etc/environment
crond -f

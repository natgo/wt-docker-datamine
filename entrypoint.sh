#!/bin/sh

printenv | grep -v "no_proxy" >> /etc/environment
crond -f
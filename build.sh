#!/bin/sh
set -e

go test

docker build -t wt-datamine .

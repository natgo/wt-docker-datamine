#!/bin/sh
set -e

node /app/datamine/dist/download.js "$1"
cd ./out/"$1"
time /app/unpack.sh

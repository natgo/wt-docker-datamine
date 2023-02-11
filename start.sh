#!/bin/sh
set -e

node /app/datamine/dist/download.js
cd ./out
time /app/unpack.sh

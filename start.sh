#!/bin/sh

node /app/datamine/dist/download.js
cd ./out
/app/unpack.sh

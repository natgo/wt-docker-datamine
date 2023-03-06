#!/bin/sh
set -e

mkdir data/ -p
# Build the docker image before running this script
docker run -v "${PWD}/data:/data" --rm --name wt-datamine wt-datamine

cd ./data/out
git status

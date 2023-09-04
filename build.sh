#!/bin/sh
set -e

go test

pnpm build
docker build -t wt-datamine .

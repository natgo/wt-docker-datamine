#!/bin/sh
pnpm build
docker build -t wt-datamine .

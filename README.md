# WT Datamine Tools
<p align="center">
  <a href="https://github.com/prettier/prettier"><img alt="code style: prettier" src="https://img.shields.io/badge/code_style-prettier-ff69b4.svg"></a>
  <img alt="GitHub" src="https://img.shields.io/github/license/natgo/wt-docker-datamine">
</p>

<p align="center">
  <a href="https://forthebadge.com/"><img src="https://forthebadge.com/images/badges/made-with-typescript.svg" alt="forthebadge"/></a>
  <a href="https://forthebadge.com/"><img src="https://forthebadge.com/images/badges/open-source.svg" alt="forthebadge"/></a>
</p>
War thunder tools for datamining

## Build

```bash
docker build -t wt-datamine .
```

## Usage

Docker Compose:
```yaml
---
version: "2.1"
services:
  wt-datamine:
    image: wt-datamine
    container_name: wt-datamine
    environment:
      - WEBHOOK=<Your Discord Webhook>
    volumes:
      - /path/to/datamine:/data
      - /path/to/oodle/oo2core_6_win64.dll:/win/oo2core_6_win64.dll:ro
    restart: unless-stopped
```

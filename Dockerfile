# Stage 1: Build Go application
FROM golang:alpine as go-builder

# Install build dependencies
RUN apk --no-cache add gcc musl-dev git python3-dev py3-pip py3-wheel

# Create a non-root user
ARG USER_UID=1000
ARG USER_GID=1000
ENV PATH="${PATH}:/home/abc/.local/bin"

RUN addgroup -S abc --gid ${USER_GID} && adduser -S abc -G abc --uid ${USER_UID}
RUN mkdir -p /data /app/datamine && chown -R abc:abc /data /app
USER abc

WORKDIR /app

RUN git clone https://github.com/kotiq/wt-tools.git && cd wt-tools/ && git checkout d89c358a3f45a725f1b190a2c1183f7288a5f80e && pip install . -r requirements.txt --break-system-packages

COPY go.mod app.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -ldflags '-w' -v -o ./app /app

# Stage 2: Build Rust application
FROM rust:alpine as rust-builder

# Install build dependencies
RUN apk --no-cache add gcc musl-dev git

# Clone and build Rust application
RUN git clone https://github.com/Warthunder-Open-Source-Foundation/wt_ext_cli.git && \
  cd wt_ext_cli/ && \
  git checkout v0.4.5 && \
  cargo build --release

# Stage 3: Create final image
FROM alpine:3.19

RUN apk add --no-cache imagemagick wine nodejs python3 busybox-openrc

# Copy go-cron file to the cron.d directory
COPY go-cron /etc/cron.d/go-cron
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/go-cron \
  # Apply cron job
  && crontab /etc/cron.d/go-cron \
  # Create the log file to be able to run tail
  && touch /var/log/cron.log && touch /etc/environment && chmod 0666 /etc/environment

RUN apk add --no-cache npm && npm install -g pnpm && apk del npm

COPY --from=go-builder /home/abc/.local /home/abc/.local

# Run as user
ARG USER_UID=1000
ARG USER_GID=1000
ENV PATH="${PATH}:/home/abc/.local/bin"

RUN addgroup -S abc --gid ${USER_GID} && adduser -S abc -G abc --uid ${USER_UID}
RUN mkdir -p /data /win /app/datamine /home/abc && chown -R abc:abc /data /win /app /home/abc
USER abc

COPY win /win/

WORKDIR /app/datamine

# Copy Node.js application files
COPY src ./src
COPY dist ./dist
COPY package.json pnpm-lock.yaml tsconfig.json ./

ARG NODE_ENV=production
RUN pnpm install --frozen-lockfile

# Switch to the application directory
WORKDIR /app

# Copy Go and Rust application binaries
COPY --from=go-builder /app/app ./
COPY --from=rust-builder /wt_ext_cli/target/release/wt_ext_cli ./

# Copy other necessary files
COPY unpack.sh start.sh entrypoint.sh ./

# Set up data directory and volumes
WORKDIR /data
VOLUME ["/data", "/win/oo2core_6_win64.dll"]

USER root

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

FROM golang:alpine as builder

# Install dependencies
RUN apk add --no-cache gcc musl-dev git python3-dev py3-pip py3-wheel 

ARG USER_UID=1000
ARG USER_GID=1000
ENV PATH="${PATH}:/home/abc/.local/bin"

RUN addgroup -S abc --gid ${USER_GID} && adduser -S abc -G abc --uid ${USER_UID}
RUN mkdir -p /data /app/datamine && chown -R abc:abc /data /app
USER abc

WORKDIR /app

RUN git clone https://github.com/kotiq/wt-tools && cd wt-tools/ && git checkout d89c358a3f45a725f1b190a2c1183f7288a5f80e && pip install . -r requirements.txt

COPY go.mod app.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -ldflags '-w' -v -o ./app /app

FROM alpine:3.17

RUN apk add --no-cache imagemagick wine nodejs python3 busybox-openrc

# Copy go-cron file to the cron.d directory
COPY go-cron /etc/cron.d/go-cron
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/go-cron
# Apply cron job
RUN crontab /etc/cron.d/go-cron
# Create the log file to be able to run tail
RUN touch /var/log/cron.log
RUN touch /etc/environment && chmod 0666 /etc/environment

RUN apk add --no-cache npm && npm install -g pnpm && apk del npm

COPY --from=builder /home/abc/.local /home/abc/.local

# Run as user
ARG USER_UID=1000
ARG USER_GID=1000
ENV PATH="${PATH}:/home/abc/.local/bin"

RUN addgroup -S abc --gid ${USER_GID} && adduser -S abc -G abc --uid ${USER_UID}
RUN mkdir -p /data /win /app/datamine /home/abc && chown -R abc:abc /data /win /app /home/abc
USER abc

COPY win /win/

WORKDIR /app/datamine

COPY src ./src
COPY dist ./dist
COPY package.json pnpm-lock.yaml tsconfig.json ./

ARG NODE_ENV=production
RUN pnpm install --frozen-lockfile

WORKDIR /app

COPY --from=builder /app/app ./

COPY unpack.sh start.sh entrypoint.sh ./

WORKDIR /data
VOLUME [ "/data" ]
VOLUME [ "/win/oo2core_6_win64.dll" ]

USER root

ENTRYPOINT [ "/app/entrypoint.sh" ]

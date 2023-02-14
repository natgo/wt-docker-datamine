FROM alpine:3.17 as builder

# Install dependencies
RUN apk add --no-cache gcc musl-dev git python3-dev py3-pip py3-wheel 

ARG USER_UID=1000
ARG USER_GID=1000
ENV PATH="${PATH}:/home/abc/.local/bin"

RUN addgroup -S abc --gid ${USER_GID} && adduser -S abc -G abc --uid ${USER_UID}
RUN mkdir -p /data /app/datamine && chown -R abc:abc /data /app
USER abc

WORKDIR /app

RUN git clone https://github.com/kotiq/wt-tools && cd wt-tools/ && pip install . -r requirements.txt

FROM alpine:3.17

RUN apk add --no-cache imagemagick wine nodejs python3

COPY --from=builder /home /home

RUN wget -qO /bin/pnpm "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" && chmod +x /bin/pnpm

# Run as user
ARG USER_UID=1000
ARG USER_GID=1000
ENV PATH="${PATH}:/home/abc/.local/bin"

RUN addgroup -S abc --gid ${USER_GID} && adduser -S abc -G abc --uid ${USER_UID}
RUN mkdir -p /data /app/datamine && chown -R abc:abc /data /app
USER abc

WORKDIR /app/datamine

COPY win ./win
COPY src ./src
COPY dist ./dist
COPY package.json pnpm-lock.yaml tsconfig.json ./

ARG NODE_ENV=production
RUN pnpm install --frozen-lockfile

WORKDIR /app

COPY unpack.sh start.sh  ./

WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/app/start.sh" ]

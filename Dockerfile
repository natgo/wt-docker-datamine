FROM alpine:3.17

# Install dependencies
RUN apk add --no-cache build-base git imagemagick wine nodejs

RUN wget -qO /bin/pnpm "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" && chmod +x /bin/pnpm

# Install python dependencies
RUN apk add --no-cache python3 python3-dev py3-pip py3-wheel

# Run as user
ARG USER_UID=1000
ARG USER_GID=1000

RUN addgroup -S abc --gid ${USER_GID} && adduser -S abc -G abc --uid ${USER_UID}
RUN mkdir -p /data /app/datamine && chown -R abc:abc /data /app
USER abc

WORKDIR /app/datamine

COPY win ./win
COPY src ./src
COPY package.json pnpm-lock.yaml tsconfig.json ./

RUN pnpm install --frozen-lockfile && pnpm build

WORKDIR /app

COPY unpack.sh start.sh  ./

# Istall wt-tools
ENV PATH="${PATH}:/home/abc/.local/bin"
RUN git clone https://github.com/kotiq/wt-tools && cd wt-tools/ && pip install . -r requirements.txt

WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/app/start.sh" ]

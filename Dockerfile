FROM alpine:3.17

# Install dependencies
RUN apk add --no-cache build-base git imagemagick wine nodejs

RUN wget -qO /bin/pnpm "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" && chmod +x /bin/pnpm

# Install python dependencies
RUN apk add --no-cache python3 python3-dev py3-pip py3-wheel

WORKDIR /app/datamine

COPY win ./win
COPY src ./src
COPY package.json pnpm-lock.yaml tsconfig.json ./

RUN pnpm install --frozen-lockfile && pnpm build

WORKDIR /app

COPY unpack.sh start.sh  ./

# Istall wt-tools
ENV PIP_ROOT_USER_ACTION=ignore
RUN git clone https://github.com/kotiq/wt-tools && cd wt-tools/ && pip install . -r requirements.txt

ENTRYPOINT [ "/app/start.sh" ]

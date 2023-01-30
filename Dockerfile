FROM alpine:3.17

# Install dependencies
RUN apk add --no-cache git imagemagick wine python3 nodejs

WORKDIR /app/datamine

COPY ./win ./win

COPY ./src ./src

COPY package.json tsconfig.json ./

RUN npm ci && npm run build

WORKDIR /app

COPY unpack.sh start.sh ./

# Istall wt-tools
RUN git clone https://github.com/kotiq/wt-tools && cd wt-tools/ && pip install . -r requirements.txt

ENTRYPOINT [ "/app/start.sh" ]

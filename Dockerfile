FROM alpine:edge as builder
LABEL stage=go-builder
WORKDIR /root/
COPY *go* .
RUN apk add --no-cache bash curl upx gcc git go musl-dev; \
    go build -ldflags='-s -w -extldflags "-static -fpic"' -o main main.go && upx -9 ./main

FROM xhofe/alist:v3.23.0
LABEL MAINTAINER="i@nn.ci"

ARG DATABASE_URL

VOLUME /opt/alist/data/
WORKDIR /opt/alist/
COPY --from=builder /root/main /main
ADD entrypoint.sh /entrypoint.sh
ADD install.sh /install.sh
RUN chmod +x /main /entrypoint.sh /install.sh; \
  /install.sh

ENV PUID=0 PGID=0 UMASK=022
EXPOSE 5244 5245 6800
ENTRYPOINT [ "/entrypoint.sh" ]

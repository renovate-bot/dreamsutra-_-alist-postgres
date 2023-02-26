FROM alpine:edge as builder
LABEL stage=go-builder
WORKDIR /root/
COPY main.go /main.go
RUN apk add --no-cache bash curl upx gcc git go musl-dev; \
    git clone https://github.com/alist-org/alist.git tmp; \
    mv tmp/.git .; \
    rm -rf tmp; \
    git reset --hard HEAD; \
    mv -f /main.go .; \
    go build -ldflags='-s -w -extldflags "-static -fpic"' -o main main.go && upx -9 ./main

FROM xhofe/alist:v2.6.4
LABEL MAINTAINER="i@nn.ci"

ARG DATABASE_URL

WORKDIR /opt/alist/
ENV DB_TYPE postgres
ENV DB_SLL_MODE require
COPY --from=builder /root/main /main
RUN chmod +x /main
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]

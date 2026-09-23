# ---- 构建阶段 ----
FROM golang:1.22-alpine AS builder

WORKDIR /src
COPY go.mod ./
RUN go mod download

COPY main.go .
# CGO_ENABLED=0 生成静态二进制，才能放进 scratch
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o app .

# ---- 运行阶段 ----
FROM scratch
# 或者用 FROM alpine:3.20 保留 shell/调试能力，镜像会大 ~7MB

COPY --from=builder /src/app /app

# 时区、证书等如果需要，可以从 alpine 拷：
# COPY --from=alpine:3.20 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8080
ENTRYPOINT ["/app"]

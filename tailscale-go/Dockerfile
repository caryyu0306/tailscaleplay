FROM golang:1.22-alpine AS builder

WORKDIR /app

# 安裝構建依賴
RUN apk add --no-cache git

# 複製 Go 模組文件
COPY go.mod go.sum* ./
RUN go mod download

# 複製源代碼
COPY . .

# 構建應用
RUN CGO_ENABLED=0 GOOS=linux go build -o tailscale-ha ./cmd/tailscale-ha

FROM tailscale/tailscale:v1.80.3

# 創建必要的目錄
RUN mkdir -p /data /share/taildrop /app

# 複製構建的二進制文件和配置
COPY --from=builder /app/tailscale-ha /usr/local/bin/
COPY --from=builder /app/config.json.example /app/
COPY docker-entrypoint.sh /app/

# 設置執行權限
RUN chmod +x /app/docker-entrypoint.sh

# 設置工作目錄
WORKDIR /app

# 暴露端口
EXPOSE 41641/udp

# 設置入口點
ENTRYPOINT ["/app/docker-entrypoint.sh"] 
# Tailscale Home Assistant 附加元件 (Go 版本)

這是 [Home Assistant Tailscale 附加元件](https://github.com/hassio-addons/addon-tailscale) 的 Go 語言重寫版本。

## 功能

- 零配置 VPN，幾分鐘內在您的 Home Assistant 實例上安裝
- 安全連接：即使被防火牆或子網分隔，Tailscale 也能正常工作
- 防火牆管理：Tailscale 為您管理防火牆規則
- 遠程訪問：從任何地方安全地訪問您的 Home Assistant 實例
- 子網路由：可以選擇將您的整個家庭網絡共享到您的 Tailscale 網絡
- 出口節點功能：可以通過您的 Home Assistant 實例路由互聯網流量
- Magic DNS：輕鬆通過名稱而不是 IP 地址訪問設備
- HTTPS 代理：為您的 Home Assistant 實例提供 TLS 證書
- Taildrop：在設備間輕鬆發送文件

## 安裝

### 使用 Docker

#### 方法 1：使用提供的腳本

1. 構建 Docker 映像：
   ```bash
   ./docker-build.sh
   ```

2. 運行 Docker 容器：
   ```bash
   ./docker-run.sh
   ```

#### 在不同平台和架構上使用

##### macOS x86 (Intel)

1. 構建 macOS x86 兼容的 Docker 映像：
   ```bash
   chmod +x docker-build-mac-x86.sh
   ./docker-build-mac-x86.sh
   ```

2. 運行 Docker 容器：
   ```bash
   chmod +x docker-run-mac-x86.sh
   ./docker-run-mac-x86.sh
   ```

3. 或者使用 Docker Compose：
   ```bash
   docker-compose -f docker-compose-mac-x86.yml up -d
   ```

##### macOS ARM (Apple Silicon)

1. 構建 macOS ARM 兼容的 Docker 映像：
   ```bash
   chmod +x docker-build-mac-arm.sh
   ./docker-build-mac-arm.sh
   ```

2. 運行 Docker 容器：
   ```bash
   chmod +x docker-run-mac-arm.sh
   ./docker-run-mac-arm.sh
   ```

3. 或者使用 Docker Compose：
   ```bash
   docker-compose -f docker-compose-mac-arm.yml up -d
   ```

##### Windows x86

1. 構建 Windows x86 兼容的 Docker 映像：
   ```cmd
   docker-build-win-x86.bat
   ```

2. 運行 Docker 容器：
   ```cmd
   docker-run-win-x86.bat
   ```

3. 或者使用 Docker Compose：
   ```cmd
   docker-compose -f docker-compose-win-x86.yml up -d
   ```

##### Windows ARM

1. 構建 Windows ARM 兼容的 Docker 映像：
   ```cmd
   docker-build-win-arm.bat
   ```

2. 運行 Docker 容器：
   ```cmd
   docker-run-win-arm.bat
   ```

3. 或者使用 Docker Compose：
   ```cmd
   docker-compose -f docker-compose-win-arm.yml up -d
   ```

##### Linux x86

1. 構建 Linux x86 兼容的 Docker 映像：
   ```bash
   chmod +x docker-build-linux-x86.sh
   ./docker-build-linux-x86.sh
   ```

2. 運行 Docker 容器：
   ```bash
   chmod +x docker-run-linux-x86.sh
   ./docker-run-linux-x86.sh
   ```

3. 或者使用 Docker Compose：
   ```bash
   docker-compose -f docker-compose-linux-x86.yml up -d
   ```

##### Linux ARM

1. 構建 Linux ARM 兼容的 Docker 映像：
   ```bash
   chmod +x docker-build-linux-arm.sh
   ./docker-build-linux-arm.sh
   ```

2. 運行 Docker 容器：
   ```bash
   chmod +x docker-run-linux-arm.sh
   ./docker-run-linux-arm.sh
   ```

3. 或者使用 Docker Compose：
   ```bash
   docker-compose -f docker-compose-linux-arm.yml up -d
   ```

#### 方法 2：使用 Docker Compose

1. 使用 Docker Compose 構建並運行：
   ```bash
   docker-compose up -d
   ```

#### 方法 3：手動運行

```bash
# 構建映像
docker build -t tailscale-ha .

# 運行容器
docker run -d --name tailscale-ha \
  --restart unless-stopped \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  --device /dev/net/tun \
  -v $(pwd)/docker-data:/data \
  -v $(pwd)/docker-share:/share \
  -p 8099:8099 \
  -p 41641:41641/udp \
  tailscale-ha
```

### 使用 Home Assistant 附加元件

1. 將此存儲庫添加到您的 Home Assistant 附加元件存儲庫中
2. 在附加元件商店中安裝 "Tailscale (Go)"
3. 啟動附加元件
4. 通過 Web UI 完成 Tailscale 認證

## 配置

配置選項與原始 Tailscale 附加元件相同：

```yaml
accept_dns: true
accept_routes: true
advertise_exit_node: true
advertise_connector: true
advertise_routes:
  - 192.168.1.0/24
  - fd12:3456:abcd::/64
funnel: false
log_level: info
login_server: "https://controlplane.tailscale.com"
proxy: false
proxy_and_funnel_port: 443
snat_subnet_routes: true
stateful_filtering: false
tags:
  - tag:example
  - tag:homeassistant
taildrop: true
userspace_networking: true
```

有關配置選項的詳細說明，請參閱 [配置文檔](https://github.com/hassio-addons/addon-tailscale/blob/main/tailscale/DOCS.md)。

## 開發

### 本地測試

使用提供的測試腳本在本地測試：

```bash
./run-test.sh
```

這將在模擬模式下運行程式，無需實際安裝 Tailscale。

### 構建

```bash
go build -o tailscale-ha ./cmd/tailscale-ha
```

### 運行

```bash
./tailscale-ha --config config.json
```

## 支持的架構

- amd64 (x86_64)
- arm64 (aarch64)
- armv7

## 許可證

MIT 許可證 
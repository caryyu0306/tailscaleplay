# Tailscale Docker 容器

![專案階段][project-stage-shield]
[![許可證][license-shield]](LICENSE.md)

![支援 aarch64 架構][aarch64-shield]
![支援 amd64 架構][amd64-shield]
![支援 armv7 架構][armv7-shield]

## 關於

這是一個簡化的 Tailscale Docker 容器部署專案，提供了方便的腳本和配置。

Tailscale 是一個零配置 VPN，幾分鐘內就可以安裝在任何設備上。它可以在您的伺服器、電腦和雲實例之間創建一個安全網絡，即使被防火牆或子網分隔，也能正常工作。

## 特點

- 零配置 VPN，簡單易用
- 安全連接：即使被防火牆或子網分隔，也能正常工作
- 自動管理防火牆規則
- 支援遠程訪問：從任何地方安全地訪問您的設備
- 支援子網路由：可以將您的整個網絡共享到您的 Tailscale 網絡
- 支援出口節點功能：可以通過您的設備路由互聯網流量
- 支援 Magic DNS：通過名稱而不是 IP 地址訪問設備
- 支援 HTTPS 代理：為您的設備提供 TLS 證書
- 支援 Taildrop：設備間輕鬆發送文件
- **新增功能**: 智能啟動檢測 - 自動顯示 Tailscale 狀態或認證 URL

## 快速開始

1. 複製 `config.json.example` 到 `options.json` 並根據需要修改配置：
   ```bash
   cp config.json.example options.json
   ```

2. 運行 Tailscale 容器：
   ```bash
   # 構建和運行 Docker 容器
   ./tailscale.sh run
   ```

   或使用認證密鑰實現自動登錄：
   ```bash
   # 使用認證密鑰運行
   ./tailscale.sh run --authkey=tskey-auth-xxxxxxxxxxxxxxxx
   ```

3. 或者，使用 Docker Compose：
   ```bash
   # 生成 docker-compose.yml 文件
   ./tailscale.sh compose
   
   # 啟動容器
   docker compose up -d
   ```

## 配置選項

您可以通過修改 `options.json` 文件來配置 Tailscale 容器。主要配置選項包括：

| 選項 | 說明 |
|------|------|
| `accept_dns` | 是否接受 DNS 設定 |
| `accept_routes` | 是否接受路由 |
| `advertise_exit_node` | 是否將節點廣告為出口節點 |
| `advertise_connector` | 是否將節點廣告為應用連接器 |
| `advertise_routes` | 要廣告的路由列表 |
| `funnel` | 是否啟用 Funnel 功能 |
| `login_server` | 登錄服務器地址 |
| `proxy` | 是否啟用 HTTPS 代理 |
| `tags` | 標籤列表 |
| `userspace_networking` | 是否使用用戶空間網絡 |

詳細配置選項請參閱 [配置指南](docs/configuration.md)。

## 持久化存儲

本專案已配置為持久性服務，這意味著：

1. Tailscale 狀態會保存在持久卷中（`docker-data` 目錄）
2. 容器重啟後會保持相同的 IP 地址和身份
3. 不需要重新認證

這是通過以下設置實現的：
- `TS_STATE_DIR=/data`：將 Tailscale 狀態存儲在持久卷中
- `TS_AUTH_ONCE=true`：容器重啟時如果已經登錄，就不會強制重新登錄

## 自動登錄

您可以使用 Tailscale 認證密鑰（Auth Key）來實現自動登錄：

```bash
./tailscale.sh run --authkey=tskey-auth-xxxxxxxxxxxxxxxx
```

要獲取認證密鑰：
1. 訪問 Tailscale 管理控制台：https://login.tailscale.com/admin/settings/keys
2. 點擊 "Generate auth key"
3. 選擇 "Reusable" 和 "Ephemeral: No"（重要！）
4. 設置有效期（例如 90 天）
5. 點擊 "Generate key"
6. 複製生成的密鑰

## 最新改進：智能啟動檢測

我們對 `tailscale.sh` 腳本進行了改進，增加了智能啟動檢測功能。這項改進使得腳本能夠：

1. **自動檢測 Tailscale 狀態**：腳本現在會主動檢查 Tailscale 的連接狀態
2. **立即顯示連接信息**：一旦 Tailscale 成功連接，立即顯示完整的狀態信息
3. **快速顯示認證 URL**：當需要認證時，立即顯示認證 URL，無需等待倒數結束

### 測試結果

測試顯示，改進後的腳本能夠：

- **快速檢測已連接狀態**：當 Tailscale 已連接時，腳本在幾秒內就能檢測到並顯示狀態
- **清晰顯示網絡信息**：顯示所有連接的設備、IP 地址和狀態
- **提供健康檢查信息**：顯示任何可能的配置問題或警告
- **支持多種認證方式**：同時支持新舊格式的認證 URL 檢測

### 實際輸出示例

```
等待 Tailscale 啟動...
等待 Tailscale 啟動 (嘗試 1/30)...
等待 Tailscale 啟動 (嘗試 2/30)...

========================================================
Tailscale 已成功啟動！
Tailscale 狀態：
100.115.135.92  tailscale            a29559089@   linux   idle; offers exit node
100.108.20.31   cary-nuc9            a29559089@   windows offline
100.97.147.4    cary-yudemacbook-air a29559089@   macOS   offline
100.95.36.99    cy0014349-caryyu     a29559089@   macOS   idle; offers exit node; offline
100.79.54.106   homeassistant        a29559089@   linux   idle; offers exit node
100.82.0.95     ipad-mini-6th-gen-wificellular a29559089@   iOS     offline
100.117.54.90   ipad-pro-12-9-gen-3  a29559089@   iOS     offline
100.79.99.39    iphone               a29559089@   iOS     offline
100.112.96.2    sh-jump              a29559089@   windows idle; offers exit node
100.90.237.3    sz                   a29559089@   windows idle; offers exit node
100.93.74.99    us-node              a29559089@   linux   idle; offers exit node; offline

# Health check:
#     - Tailscale failed to fetch the DNS configuration of your device: getting OS base config is not supported
#     - getting OS base config is not supported
#     - Some peers are advertising routes but --accept-routes is false
========================================================
```

### 優點

1. **更好的用戶體驗**：用戶可以立即看到 Tailscale 的狀態，無需等待
2. **更容易排除故障**：顯示詳細的連接信息和健康檢查結果
3. **減少等待時間**：一旦 Tailscale 準備就緒，立即停止等待
4. **更清晰的狀態顯示**：明確區分已連接狀態和需要認證的情況

## 文檔

詳細文檔請參閱 [docs](docs) 目錄：

- [配置指南](docs/configuration.md)
- [故障排除](docs/troubleshooting.md)
- [Docker 使用指南](docs/docker.md)
- [常見問題解答](docs/faq.md)

## 故障排除

### Docker 實驗性功能錯誤

如果您在執行 `./tailscale.sh run` 時遇到以下錯誤：

```
"--platform" is only supported on a Docker daemon with experimental features enabled
```

這是因為腳本使用了 Docker 的 `--platform` 參數，但您的 Docker daemon 沒有啟用實驗性功能。您可以選擇以下兩種解決方案之一：

#### 解決方案一：啟用 Docker daemon 的實驗性功能

1. 編輯或創建 Docker daemon 配置文件：
   ```bash
   sudo mkdir -p /etc/docker
   sudo nano /etc/docker/daemon.json
   ```

2. 在文件中添加以下內容：
   ```json
   {
     "experimental": true
   }
   ```

3. 保存文件並重啟 Docker 服務：
   ```bash
   sudo systemctl restart docker
   ```

4. 重新執行 tailscale.sh 腳本：
   ```bash
   ./tailscale.sh run
   ```

#### 解決方案二：修改 tailscale.sh 腳本，移除 --platform 參數

這是一個更簡單的解決方案，特別是如果您的系統架構與容器架構相同：

1. 編輯 tailscale.sh 文件：
   ```bash
   nano tailscale.sh
   ```

2. 找到 docker run 命令（大約在第 300 行左右），移除 `--platform=${PLATFORM}` 這一行。修改前：
   ```bash
   docker run -d --name ${CONTAINER_NAME} \
     --platform=${PLATFORM} \
     --hostname ${CONTAINER_NAME} \
     --restart unless-stopped \
     ...
   ```

   修改後：
   ```bash
   docker run -d --name ${CONTAINER_NAME} \
     --hostname ${CONTAINER_NAME} \
     --restart unless-stopped \
     ...
   ```

3. 如果您使用 `compose` 命令，也需要修改腳本中生成 docker-compose.yml 的部分，移除 `platform: $PLATFORM` 行。

## 許可證

MIT 許可證

Copyright (c) 2021-2025

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[license-shield]: https://img.shields.io/badge/license-MIT-blue.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg

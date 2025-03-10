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

## 文檔

詳細文檔請參閱 [docs](docs) 目錄：

- [配置指南](docs/configuration.md)
- [故障排除](docs/troubleshooting.md)
- [Docker 使用指南](docs/docker.md)
- [常見問題解答](docs/faq.md)

## 許可證

MIT 許可證

Copyright (c) 2021-2025

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[license-shield]: https://img.shields.io/badge/license-MIT-blue.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg

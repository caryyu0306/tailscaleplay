# Tailscale Docker 容器配置指南

本文檔介紹了 Tailscale Docker 容器的配置選項。適當的配置可以幫助您充分利用 Tailscale 功能。

## 配置方式

本專案提供了兩種配置方式：

1. 通過 `options.json` 文件進行配置
2. 通過環境變量直接配置 Docker 容器

大多數情況下，使用 `options.json` 文件進行配置是最簡單的方式，因為 `tailscale.sh` 腳本會自動將此文件中的配置轉換為相應的環境變量。

## 基本配置

Tailscale 的大部分網絡配置都是通過 Tailscale 的網頁界面完成的：[https://login.tailscale.com/](https://login.tailscale.com/)

考慮禁用密鑰過期以避免失去與您的設備的連接。有關更多信息，請參閱 [密鑰過期](https://tailscale.com/kb/1028/key-expiry)。

## JSON 配置參考

以下是 `options.json` 文件中可用的配置選項：

```json
{
  "accept_dns": true,
  "accept_routes": true,
  "advertise_exit_node": true,
  "advertise_connector": true,
  "advertise_routes": [
    "192.168.0.0/16"
  ],
  "funnel": false,
  "log_level": "info",
  "login_server": "https://controlplane.tailscale.com",
  "proxy": false,
  "proxy_and_funnel_port": "443",
  "snat_subnet_routes": true,
  "stateful_filtering": false,
  "tags": [
    "tag:homeassistant"
  ],
  "taildrop": true,
  "userspace_networking": true
}
```

## 配置選項詳解

| 選項 | 環境變量 | 說明 |
|------|----------|------|
| `accept_dns` | `TS_ACCEPT_DNS` | 接受 DNS 配置，默認為 `false` |
| `accept_routes` | `TS_EXTRA_ARGS` 包含 `--accept-routes` | 接受來自其他節點的路由 |
| `advertise_exit_node` | `TS_EXTRA_ARGS` 包含 `--advertise-exit-node` | 將此節點廣告為出口節點 |
| `advertise_connector` | `TS_EXTRA_ARGS` 包含 `--advertise-connector` | 將此節點廣告為應用連接器 |
| `advertise_routes` | `TS_ROUTES` | 要廣告的子網路由列表 |
| `funnel` | `TS_FUNNEL` | 啟用 Funnel 功能，將請求轉發到此設備 |
| `log_level` | `TS_LOG_LEVEL` | 日誌級別，可選值：`debug`、`info`、`error` |
| `login_server` | `TS_LOGIN_SERVER` | Tailscale 登錄服務器地址 |
| `proxy` | `TS_PROXY` | 啟用 HTTPS 代理功能 |
| `proxy_and_funnel_port` | `TS_PORT` | Proxy 和 Funnel 使用的端口 |
| `snat_subnet_routes` | `TS_SNAT_SUBNET_ROUTES` | 對子網路由使用源 NAT |
| `stateful_filtering` | `TS_STATEFUL_FILTERING` | 啟用有狀態過濾 |
| `tags` | `TS_TAGS` | 應用於此節點的標籤列表 |
| `taildrop` | `TS_TAILDROP` | 啟用 Taildrop 文件傳輸功能 |
| `userspace_networking` | `TS_USERSPACE` | 使用用戶空間網絡（適用於容器） |

## 持久性存儲配置

本專案已配置為持久性服務，這意味著容器重啟後會保持相同的 IP 地址和身份，不需要重新認證。這是通過以下設置實現的：

- `TS_STATE_DIR=/data`：將 Tailscale 狀態存儲在持久卷中（`docker-data` 目錄）
- `TS_AUTH_ONCE=true`：容器重啟時如果已經登錄，就不會強制重新登錄

## 自動登錄配置

您可以使用 Tailscale 認證密鑰（Auth Key）來實現自動登錄：

```bash
./tailscale.sh run --authkey=tskey-auth-xxxxxxxxxxxxxxxx
```

### 獲取認證密鑰

1. 訪問 Tailscale 管理控制台：https://login.tailscale.com/admin/settings/keys
2. 點擊 "Generate auth key"
3. 選擇 "Reusable" 和 "Ephemeral: No"（重要！）
4. 設置有效期（例如 90 天）
5. 點擊 "Generate key"
6. 複製生成的密鑰

## 高級配置

以下是一些高級配置選項：

### 出口節點配置

將設備配置為出口節點，可以讓您通過此設備路由所有互聯網流量：

1. 在 `options.json` 中設置 `"advertise_exit_node": true`
2. 在 Tailscale 管理控制台中啟用此功能
3. 在其他設備上選擇此節點作為出口節點

### 子網路由配置

廣告子網路由可以讓其他 Tailscale 設備訪問您本地網絡中的設備：

1. 在 `options.json` 中設置 `"advertise_routes": ["192.168.0.0/16"]`
2. 在 Tailscale 管理控制台中批准此路由
3. 在其他設備上接受此路由

### 標籤配置

標籤可用於通過存取控制（ACL）管理設備權限：

1. 在 `options.json` 中設置 `"tags": ["tag:homeassistant"]`
2. 在 Tailscale 管理控制台中創建和管理 ACL 規則

## 配置示例

### 基本配置示例

```json
{
  "accept_dns": true,
  "userspace_networking": true
}
```

### 出口節點配置示例

```json
{
  "accept_dns": true,
  "advertise_exit_node": true,
  "userspace_networking": true
}
```

### 子網路由配置示例

```json
{
  "accept_dns": true,
  "advertise_routes": [
    "192.168.0.0/16"
  ],
  "snat_subnet_routes": true,
  "userspace_networking": true
}
```

### 完整配置示例

```json
{
  "accept_dns": true,
  "accept_routes": true,
  "advertise_exit_node": true,
  "advertise_connector": true,
  "advertise_routes": [
    "192.168.0.0/16"
  ],
  "funnel": false,
  "log_level": "info",
  "login_server": "https://controlplane.tailscale.com",
  "proxy": false,
  "proxy_and_funnel_port": "443",
  "snat_subnet_routes": true,
  "stateful_filtering": false,
  "tags": [
    "tag:homeassistant"
  ],
  "taildrop": true,
  "userspace_networking": true
}
``` 
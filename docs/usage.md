# Tailscale Home Assistant 附加元件使用指南

本指南將幫助您了解如何有效使用 Tailscale Home Assistant 附加元件來增強您的智能家居體驗。

## 基本用途

安裝並配置 Tailscale 附加元件後，您可以：

1. **遠程訪問您的 Home Assistant 實例**：
   - 從任何安裝了 Tailscale 的設備上，您可以通過 Tailscale IP 地址訪問您的 Home Assistant 實例。
   - 如果啟用了 MagicDNS，您可以使用類似 `homeassistant` 的主機名訪問。

2. **安全訪問您的本地網絡**：
   - 如果您配置了子網路由，您可以從任何 Tailscale 連接的設備訪問您的本地網絡中的設備。

3. **使用出口節點功能**：
   - 讓您的 Home Assistant 實例充當 VPN 出口節點，允許您在不信任的網絡上安全瀏覽互聯網。

## 常見使用場景

### 場景 1：遠程訪問 Home Assistant

當您不在家但需要訪問您的 Home Assistant 時：

1. 在您的移動設備或計算機上安裝 Tailscale 客戶端：
   - [Android](https://play.google.com/store/apps/details?id=com.tailscale.ipn)
   - [iOS](https://apps.apple.com/us/app/tailscale/id1470499037)
   - [Windows](https://tailscale.com/download/windows)
   - [macOS](https://tailscale.com/download/macos)
   - [Linux](https://tailscale.com/download/linux)

2. 使用您的 Tailscale 帳戶登錄客戶端

3. 連接成功後，打開瀏覽器並訪問您的 Home Assistant：
   - 使用 Tailscale IP 地址：`http://100.x.y.z:8123`（具體 IP 在您的 Tailscale 管理控制台中可見）
   - 或者，如果啟用了 MagicDNS：`http://homeassistant:8123`

### 場景 2：訪問本地網絡設備

當您需要從外部訪問您家中的其他設備時：

1. 確保已在 Tailscale 附加元件中配置了 `advertise_routes` 選項，包含您的本地子網

2. 在 Tailscale 管理控制台（https://login.tailscale.com）中批准路由

3. 現在，您可以從任何連接到 Tailscale 的設備訪問您家中的設備：
   - 例如，如果您的本地 NAS 的 IP 是 192.168.1.50，您可以直接使用該 IP 地址連接它

### 場景 3：使用出口節點功能

當您在公共 Wi-Fi 上並想安全地瀏覽互聯網時：

1. 確保在 Tailscale 附加元件中啟用了 `advertise_exit_node` 選項

2. 在 Tailscale 管理控制台的 [設置頁面](https://login.tailscale.com/admin/settings) 中，找到並啟用出口節點功能

3. 在您的設備上（例如筆記本電腦或手機）：
   - 打開 Tailscale 客戶端
   - 選擇您的 Home Assistant 實例作為出口節點
   - 所有互聯網流量現在將通過您的家庭網絡路由

## 高級功能

### Taildrop 文件傳輸

Taildrop 允許您在 Tailscale 設備之間發送文件：

1. 確保在附加元件配置中啟用了 `taildrop` 選項

2. 要向您的 Home Assistant 實例發送文件：
   - 在支持 Taildrop 的 Tailscale 客戶端上，選擇要發送的文件
   - 選擇您的 Home Assistant 實例作為目標
   - 文件將被發送並存儲在 `/share/taildrop` 目錄中

### Tailscale Funnel 公共訪問

如果您想從沒有 Tailscale 的設備訪問您的 Home Assistant：

1. 在附加元件配置中啟用 `proxy` 和 `funnel` 選項

2. 按照 [配置指南](configuration.md) 中的步驟配置 Home Assistant 的 HTTP 集成

3. 在 Tailscale 管理控制台的訪問控制頁面添加必要的 `funnel` 節點屬性

4. 重新啟動附加元件

5. 現在，您可以通過您的 Tailscale 域名（如 `https://homeassistant.tail1234.ts.net`）訪問您的 Home Assistant 實例，即使在沒有安裝 Tailscale 的設備上也可以

## 提示和技巧

1. **使用 MagicDNS**：啟用 MagicDNS 可以讓您使用友好的主機名而不是 IP 地址來訪問設備。

2. **ACL 和訪問控制**：使用 Tailscale 的 ACL（訪問控制列表）功能來限制誰可以訪問您的設備和服務。

3. **標籤**：使用標籤來組織和管理設備，特別是在具有多個設備的複雜設置中。

4. **密鑰輪換**：考慮為敏感設備，如您的 Home Assistant 實例，禁用密鑰過期，以避免意外失去訪問權限。

5. **設備批准**：配置 Tailscale 以要求管理員批准新設備，增加安全層級。

## 故障排除

如果您在使用 Tailscale 附加元件時遇到問題，請參考 [故障排除指南](troubleshooting.md)。 
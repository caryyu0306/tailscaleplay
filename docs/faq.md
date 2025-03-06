# Tailscale Home Assistant 附加元件常見問題

本文檔回答了關於 Tailscale Home Assistant 附加元件的常見問題。

## 基本問題

### 什麼是 Tailscale？

Tailscale 是一種零配置 VPN 服務，使用基於 WireGuard 的技術創建一個安全的網格網絡（稱為 tailnet）。它允許您在不同網絡上的設備之間建立加密連接，無需複雜的配置或端口轉發。

### Tailscale 與傳統 VPN 相比有什麼優勢？

Tailscale 相比傳統 VPN 有幾個主要優勢：
- **更簡單的設置**：無需端口轉發或複雜的網絡配置
- **點對點連接**：設備直接相互連接，而不是通過中央服務器
- **更好的性能**：點對點連接通常提供更低的延遲和更高的吞吐量
- **基於身份的網絡**：使用現代身份提供者進行認證
- **精細的訪問控制**：可以精確控制誰可以訪問哪些資源

### Tailscale 對於 Home Assistant 用戶有什麼好處？

- **安全的遠程訪問**：無需開放您的家庭網絡或配置端口轉發
- **簡化的移動訪問**：從任何地方輕鬆訪問您的 Home Assistant 實例
- **增強的隱私**：所有連接都是端到端加密的
- **子網路由**：可以訪問您的整個家庭網絡中的其他設備
- **跨平台支持**：適用於所有主要操作系統和設備

## 安裝和設置

### 我需要 Tailscale 帳戶嗎？

是的，您需要一個 Tailscale 帳戶來使用此附加元件。您可以在 [https://login.tailscale.com/start](https://login.tailscale.com/start) 創建一個免費帳戶，它允許一個用戶最多連接 100 個設備。

### Tailscale 收費嗎？

Tailscale 提供免費和付費計劃：
- **個人計劃（免費）**：單用戶，最多 100 個設備，基本功能
- **個人專業版和團隊計劃**：提供更多功能，如共享節點、額外的用戶和高級支持

對於大多數家庭用戶，免費計劃通常足夠。詳情請參閱 [Tailscale 定價頁面](https://tailscale.com/pricing/)。

### 我可以同時運行 Tailscale 和其他 VPN 嗎？

是的，Tailscale 設計為可以與其他 VPN 解決方案共存。Tailscale 創建的路由僅適用於您的 tailnet 內的地址，不會干擾其他 VPN 連接。

### 我如何更新 Tailscale 附加元件？

附加元件可以通過 Home Assistant 的標準附加元件界面更新。當有新版本可用時，您會在 Home Assistant 的附加元件部分看到更新通知。

## 使用和功能

### 如何檢查我的 Tailscale 連接狀態？

您可以通過查看附加元件的日誌或訪問 Tailscale 管理控制台 ([https://login.tailscale.com](https://login.tailscale.com)) 來檢查連接狀態。

### 我如何查找我的 Tailscale IP 地址？

您可以在 Tailscale 管理控制台 ([https://login.tailscale.com](https://login.tailscale.com)) 中查看您的 Tailscale IP 地址，或者在附加元件的日誌中查找它。它通常是以 `100.` 開頭的 IPv4 地址。

### 什麼是 MagicDNS，我應該使用它嗎？

MagicDNS 是 Tailscale 的一項功能，允許您使用設備名稱而不是 IP 地址來訪問 tailnet 中的設備。它通常推薦使用，因為它使訪問設備變得更加方便。

要啟用 MagicDNS：
1. 登錄 Tailscale 管理控制台
2. 前往 DNS 設置
3. 啟用 MagicDNS

### 我應該將 Home Assistant 配置為出口節點嗎？

將您的 Home Assistant 實例配置為出口節點可以讓您從任何地方通過您的家庭網絡路由互聯網流量。這在使用不受信任的網絡（如公共 Wi-Fi）時非常有用。

考慮因素：
- **優點**：增強隱私，繞過地理限制
- **缺點**：增加您的家庭網絡的帶寬使用，可能影響性能

### Tailscale 與 Nabu Casa 遠程訪問相比如何？

Tailscale 和 Nabu Casa 提供不同的遠程訪問方法：

- **Nabu Casa**：
  - 官方支持的 Home Assistant 遠程訪問解決方案
  - 包括 SSL 證書和簡單的設置
  - 是一種支持 Home Assistant 項目的訂閱服務

- **Tailscale**：
  - 更通用的 VPN 解決方案，不僅限於 Home Assistant
  - 提供對整個家庭網絡的訪問
  - 基本使用免費
  - 需要在每個客戶端設備上安裝 Tailscale

## 故障排除

### 附加元件啟動了，但我無法連接到我的 Home Assistant 實例

檢查以下幾點：
1. 確保您的設備已連接到相同的 Tailscale 帳戶
2. 檢查 Tailscale 管理控制台中的設備狀態
3. 確認您正在使用正確的 IP 地址或主機名
4. 檢查附加元件的日誌是否有錯誤信息

### 我無法在移動設備上訪問我的本地網絡設備

如果您已配置子網路由但仍無法訪問本地設備：
1. 確保您已在附加元件配置中添加了正確的子網路由
2. 檢查您是否在 Tailscale 管理控制台中批准了這些路由
3. 確認您的本地網絡設備配置正確
4. 檢查防火牆設置是否可能阻止連接

### 如何解決 MagicDNS 問題？

如果 MagicDNS 不起作用：
1. 確保在 Tailscale 管理控制台中啟用了 MagicDNS
2. 如果您使用的是 Pi-hole 或 AdGuard Home，考慮禁用附加元件中的 `accept_dns` 選項
3. 檢查網絡連接問題
4. 嘗試重新啟動 Tailscale 附加元件

### Tailscale Funnel 功能不工作

如果您已設置 Tailscale Funnel 但無法從外部訪問：
1. 確保您正確配置了 Home Assistant 的 `configuration.yaml` 中的 HTTP 集成
2. 檢查您是否在 Tailscale 管理控制台中設置了必要的 ACL 策略
3. 注意 Funnel 設置後可能需要長達 10 分鐘才能生效
4. 嘗試清除瀏覽器緩存和 cookie

### 如何重置 Tailscale 附加元件？

如果您需要重置附加元件：
1. 在 Tailscale 管理控制台中刪除設備
2. 卸載並重新安裝附加元件
3. 按照安裝指南重新配置

## 隱私和安全

### Tailscale 如何處理我的數據？

Tailscale 的設計注重隱私：
- 流量直接在您的設備間流動，不通過 Tailscale 服務器
- Tailscale 的控制服務器只用於協調連接，不處理實際的網絡流量
- 所有連接都是端到端加密的

詳細隱私政策可在 [Tailscale 隱私政策頁面](https://tailscale.com/privacy-policy/) 找到。

### Tailscale 是開源的嗎？

Tailscale 客戶端的大部分代碼是開源的，可在 [GitHub](https://github.com/tailscale) 上找到。然而，某些組件和控制服務器代碼是專有的。Tailscale 基於開源的 [WireGuard](https://www.wireguard.com/) 協議。

### Tailscale 如何提高我的 Home Assistant 安全性？

Tailscale 通過以下方式提高安全性：
- 無需開放端口或設置端口轉發，減少了攻擊面
- 所有流量都是加密的，即使在不安全的網絡上也是如此
- 基於身份的訪問控制，比簡單的密碼認證更安全
- 可以限制特定設備或用戶的訪問

## 高級使用

### 我可以在 Tailscale 內限制對特定服務或設備的訪問嗎？

是的，Tailscale 提供了訪問控制列表 (ACL) 功能，允許您精確控制誰可以訪問您網絡上的哪些資源。這些策略可以在 Tailscale 管理控制台的 [訪問控制頁面](https://login.tailscale.com/admin/acls) 配置。

### 我可以將我的整個家庭網絡暴露給 Tailscale 嗎？

是的，使用子網路由功能可以將您的整個家庭網絡暴露給您的 Tailscale 網絡。這是通過在附加元件配置中配置 `advertise_routes` 選項完成的。

### 如何在 Tailscale 中使用自定義域名？

要在 Tailscale 中使用自定義域名：
1. 在 Tailscale 管理控制台中啟用 MagicDNS
2. 配置 HTTPS 證書（如果您想要 HTTPS 支持）
3. 在 Tailscale DNS 設置中添加 DNS 記錄

### 可以有多個設備作為子網路由器嗎？

是的，您可以在 Tailscale 網絡中有多個子網路由器。這對於連接多個物理位置或提供冗餘很有用。每個路由器需要配置為通告其連接的子網。

## 相容性和整合

### Tailscale 與哪些操作系統兼容？

Tailscale 支持多種操作系統，包括：
- Windows
- macOS
- Linux（多種發行版）
- iOS
- Android
- FreeBSD
- OpenBSD
- 各種 NAS 系統（Synology、QNAP 等）

### Tailscale 是否能與其他 Home Assistant 附加元件一起工作？

是的，Tailscale 通常可以與其他 Home Assistant 附加元件一起使用。不過，與其他網絡相關的附加元件（如其他 VPN 解決方案）可能需要特別注意配置，以避免衝突。

### 如何將 Tailscale 與我的 DNS 設置（如 Pi-hole 或 AdGuard Home）整合？

如果您使用 Pi-hole 或 AdGuard Home：
1. 在附加元件配置中禁用 `accept_dns` 選項
2. 在您的 DNS 服務中添加 `100.100.100.100`（Tailscale 的 DNS 服務器）作為上游 DNS 服務器
3. 確保您的 Tailscale 設備配置為使用您的本地 DNS 服務器

## 其他信息

### 在哪裡可以找到更多關於 Tailscale 的信息？

- [Tailscale 官方文檔](https://tailscale.com/kb/)
- [Tailscale GitHub 存儲庫](https://github.com/tailscale)
- [Tailscale 博客](https://tailscale.com/blog/)
- [Home Assistant 社區論壇](https://community.home-assistant.io/)

### 如何報告問題或請求功能？

- 對於 Tailscale 附加元件相關問題：在 [GitHub 問題跟踪器](https://github.com/hassio-addons/addon-tailscale/issues) 提交問題
- 對於 Tailscale 服務相關問題：聯繫 [Tailscale 支持](https://tailscale.com/contact/support/)
- 對於功能請求：可以在 GitHub 存儲庫上提出，或參與 Home Assistant 社區討論

### 這個附加元件是官方的嗎？

這是 Home Assistant 社區附加元件，而不是官方的 Home Assistant 核心集成。它由 Home Assistant 社區成員創建和維護，而不是 Tailscale 或 Home Assistant 團隊直接維護。然而，它是一個廣泛使用和良好支持的附加元件。 
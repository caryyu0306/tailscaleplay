# Tailscale Home Assistant 附加元件故障排除指南

本文檔提供解決使用 Tailscale Home Assistant 附加元件時可能遇到的常見問題的步驟。

## 診斷工具

在開始故障排除之前，以下診斷工具和資源可能會有幫助：

1. **附加元件日誌**：
   - 在 Home Assistant 中，前往 **Supervisor** > **附加元件** > **Tailscale**
   - 選擇 **日誌** 選項卡查看詳細的運行日誌

2. **Tailscale 管理控制台**：
   - 前往 [https://login.tailscale.com](https://login.tailscale.com)
   - 檢查連接的設備、它們的狀態和 IP 地址

3. **Tailscale CLI**：
   - 在支持的設備上，您可以使用 `tailscale status` 命令檢查連接狀態
   - 在 Home Assistant OS 中，您可以通過 SSH 附加元件或直接 SSH 訪問

## 常見問題及解決方案

### 問題：無法啟動附加元件

**症狀**：附加元件無法啟動，在日誌中顯示錯誤。

**可能的解決方案**：
1. 檢查您的 Home Assistant 是否有足夠的資源（內存和 CPU）
2. 檢查網絡連接是否正常
3. 嘗試重新啟動 Home Assistant
4. 如果問題持續，嘗試卸載並重新安裝附加元件

### 問題：附加元件啟動，但無法通過 Web UI 認證

**症狀**：附加元件顯示為正在運行，但當您嘗試通過 Web UI 認證時，頁面無法加載或認證失敗。

**可能的解決方案**：
1. 嘗試使用不同的瀏覽器（推薦 Chrome）
2. 清除瀏覽器緩存和 cookie
3. 檢查日誌中是否有網絡相關錯誤
4. 確保您的 Home Assistant 實例可以訪問互聯網
5. 如果您使用的是自定義的 `login_server`，請驗證其配置是否正確

### 問題：無法從其他設備訪問 Home Assistant

**症狀**：Tailscale 顯示為已連接，但您無法從其他 Tailscale 設備訪問您的 Home Assistant 實例。

**可能的解決方案**：
1. 確保您使用的是正確的 Tailscale IP 地址和端口（通常是 `http://100.x.y.z:8123`）
2. 檢查您的 Home Assistant 的 `configuration.yaml` 是否有任何可能阻止外部訪問的設置
3. 測試基本的網絡連接，例如使用 `ping` 命令
4. 檢查 Tailscale 管理控制台中的設備是否都正確連接和在線
5. 檢查 Tailscale ACL 策略是否可能限制訪問

### 問題：子網路由不工作

**症狀**：您已配置 `advertise_routes`，但無法從 Tailscale 設備訪問您的本地網絡。

**可能的解決方案**：
1. 確保您已在 Tailscale 管理控制台中批准了子網路由（在 [路由設置](https://login.tailscale.com/admin/machines) 中）
2. 檢查 `advertise_routes` 配置是否包含正確的子網 CIDR
3. 確保 `snat_subnet_routes` 設置為 `true`（除非您有特定原因禁用它）
4. 檢查您的本地路由器或防火牆是否可能阻止流量
5. 嘗試使用 `ip route` 命令（在支持的設備上）查看路由表

### 問題：MagicDNS 不工作

**症狀**：您無法使用主機名訪問您的 Tailscale 設備，只能使用 IP 地址。

**可能的解決方案**：
1. 確保在 Tailscale 管理控制台的 [DNS 設置](https://login.tailscale.com/admin/dns) 中啟用了 MagicDNS
2. 如果您使用的是自己的 DNS 服務器（如 Pi-hole），請在附加元件配置中將 `accept_dns` 設置為 `false`
3. 在您的 DNS 服務器中添加 `100.100.100.100` 作為上游 DNS 服務器
4. 嘗試刷新 DNS 緩存
5. 檢查您的設備是否正確配置為使用 Tailscale 的 DNS 服務器

### 問題：出口節點功能不工作

**症狀**：您已配置 `advertise_exit_node`，但無法將流量路由通過您的 Home Assistant 實例。

**可能的解決方案**：
1. 確保在 Tailscale 管理控制台的 [設置頁面](https://login.tailscale.com/admin/settings) 中啟用了出口節點功能
2. 在客戶端設備上正確選擇您的 Home Assistant 實例作為出口節點
3. 檢查您的 Home Assistant 主機的防火牆設置
4. 確保 IP 轉發已啟用（附加元件應自動處理這一點）
5. 檢查您的互聯網服務提供商是否阻止了此類流量

### 問題：Taildrop 文件共享不工作

**症狀**：您無法使用 Taildrop 功能發送文件到您的 Home Assistant 實例。

**可能的解決方案**：
1. 確保 `taildrop` 選項在附加元件配置中設置為 `true`
2. 檢查您是否有足夠的存儲空間
3. 確認您的客戶端設備支持 Taildrop
4. 檢查文件大小限制（Taildrop 有最大文件大小限制）
5. 檢查 `/share/taildrop` 目錄的權限

### 問題：Tailscale Funnel / HTTPS 代理無法正常工作

**症狀**：您已配置 `proxy` 或 `funnel`，但無法通過安全 HTTPS 連接或從外部訪問您的 Home Assistant。

**可能的解決方案**：
1. 確保您已正確配置 Home Assistant 的 `configuration.yaml`，包括：
   ```yaml
   http:
     use_x_forwarded_for: true
     trusted_proxies:
       - 127.0.0.1
   ```
2. 檢查您是否已在 Tailscale 管理控制台中正確配置了 DNS 和 HTTPS 證書
3. 確保您為 Funnel 功能配置了正確的 ACL 策略
4. 注意配置後可能需要長達 10 分鐘才能生效
5. 嘗試清除瀏覽器緩存和 cookie

### 問題：與其他 VPN 或網絡服務衝突

**症狀**：Tailscale 與其他 VPN 解決方案或網絡服務衝突。

**可能的解決方案**：
1. 確保路由不重疊
2. 在路由表中比較優先級
3. 考慮使用 `userspace_networking: true`（默認設置）來減少衝突
4. 如果必要，為不同的 VPN 服務配置不同的路由表或優先級

## 高級故障排除

### 檢查網絡連接

使用以下命令測試基本網絡連接：

```bash
# 從 Tailscale 設備 ping Home Assistant 實例
ping 100.x.y.z  # 替換為您的 Tailscale IP

# 使用 tailscale ping 特定測試工具
tailscale ping hostname
```

### 檢查路由

在支持的設備上（如 Linux），您可以檢查路由表：

```bash
ip route
ip route show table all
```

### 獲取詳細的 Tailscale 狀態

使用 Tailscale CLI 獲取詳細狀態：

```bash
tailscale status
tailscale netcheck  # 網絡連接診斷
```

### 檢查 DNS 解析

測試 DNS 解析是否正常工作：

```bash
# 使用 dig 測試 DNS 解析
dig @100.100.100.100 hostname.ts.net

# 或使用 nslookup
nslookup hostname.ts.net 100.100.100.100
```

## 尋求幫助

如果您已嘗試了上述解決方案但問題仍然存在，可以尋求進一步幫助：

1. **Home Assistant 社區論壇**：
   - 前往 [Home Assistant 社區論壇](https://community.home-assistant.io/)
   - 在關於附加元件的部分發帖
   - 詳細描述您的問題、已嘗試的解決方案和錯誤消息

2. **GitHub 問題跟踪器**：
   - 前往 [附加元件的 GitHub 存儲庫](https://github.com/hassio-addons/addon-tailscale/issues)
   - 創建一個新的問題，提供相關詳細信息

3. **Discord 社區**：
   - 加入 [Home Assistant Discord 服務器](https://discord.gg/c5DvZ4e)
   - 在適當的頻道中尋求幫助

在尋求幫助時，請提供以下信息：
- 附加元件版本
- Home Assistant 版本
- 操作系統和硬件詳細信息
- 完整的錯誤消息和日誌（請移除任何敏感信息）
- 您已嘗試的故障排除步驟 
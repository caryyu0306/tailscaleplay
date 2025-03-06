# Tailscale Home Assistant 附加元件快速入門指南

本快速入門指南將幫助您快速設置和開始使用 Tailscale Home Assistant 附加元件。

## 什麼是 Tailscale？

Tailscale 是一種零配置 VPN，可讓您在不同設備和網絡之間建立安全連接。使用 Tailscale，您可以：

- 從任何地方安全地訪問您的 Home Assistant
- 無需端口轉發或 DynamicDNS
- 連接到您家中的所有智能家居設備
- 在公共 Wi-Fi 上安全地瀏覽互聯網

## 安裝前的準備

在開始之前，您需要：

1. 一個運行中的 Home Assistant 實例（OS、Supervised 或 Container）
2. Tailscale 帳戶（可以在安裝過程中創建）
3. 良好的互聯網連接

## 10 分鐘快速設置

### 步驟 1：安裝附加元件

1. 在 Home Assistant 中，導航到 **Supervisor** > **附加元件商店**
2. 如果您還沒有添加 Home Assistant 社區附加元件存儲庫：
   - 點擊右上角三點菜單 > **存儲庫**
   - 添加 `https://github.com/hassio-addons/repository`
3. 搜索 "Tailscale" 並點擊該附加元件
4. 點擊 **安裝** 按鈕

### 步驟 2：啟動附加元件

1. 安裝完成後，點擊 **啟動** 按鈕
2. 等待附加元件啟動（可能需要幾秒鐘）
3. 確認附加元件狀態顯示為"已啟動"

### 步驟 3：連接到您的 Tailscale 帳戶

1. 點擊 **打開網頁 UI** 按鈕
2. 如果您還沒有 Tailscale 帳戶，請創建一個
3. 登錄您的 Tailscale 帳戶
4. 授權 Home Assistant 連接到您的 Tailscale 網絡
5. 待認證完成後，您將被重定向回附加元件界面

### 步驟 4：檢查連接

1. 回到附加元件的詳情頁面
2. 查看日誌，確認類似"Tailscale 已啟動並運行中"的消息
3. 記下您的 Tailscale IP 地址（通常是 `100.x.y.z` 格式）

### 步驟 5：從另一台設備連接

1. 在您想要用來訪問 Home Assistant 的設備上安裝 Tailscale 客戶端：
   - [iOS](https://apps.apple.com/us/app/tailscale/id1470499037)
   - [Android](https://play.google.com/store/apps/details?id=com.tailscale.ipn)
   - [Windows/macOS/Linux](https://tailscale.com/download)
2. 使用相同的 Tailscale 帳戶登錄
3. 連接後，打開瀏覽器並訪問：`http://100.x.y.z:8123`
   （將 `100.x.y.z` 替換為您的 Home Assistant 的 Tailscale IP 地址）
4. 您現在應該可以安全地訪問您的 Home Assistant 界面了！

## 後續步驟

恭喜！您現在已經設置了 Tailscale 來安全地訪問您的 Home Assistant。接下來您可以：

1. **啟用 MagicDNS**：這樣您就可以使用名稱（如 `homeassistant:8123`）而不是 IP 地址訪問
2. **配置子網路由**：為了訪問您家中的其他設備
3. **設置出口節點**：使您可以通過家庭網絡安全地瀏覽互聯網
4. **探索 Taildrop**：在設備間輕鬆發送文件

查看詳細的 [配置指南](configuration.md) 和 [使用指南](usage.md) 了解更多高級功能。

## 快速故障排除

如果您遇到問題：

- **無法連接**：確保所有設備都登錄到相同的 Tailscale 帳戶
- **看不到 Web UI**：嘗試使用 Chrome 瀏覽器，有些瀏覽器可能無法正確加載界面
- **附加元件無法啟動**：檢查日誌以獲取詳細錯誤信息
- **無法通過名稱訪問**：確保已啟用 MagicDNS

如需更深入的故障排除指導，請參閱 [故障排除指南](troubleshooting.md)。 
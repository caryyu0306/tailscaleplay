# Tailscale Home Assistant 附加元件安裝指南 (Go 版本)

本指南將幫助您在 Home Assistant 上安裝和設置 Tailscale Go 版本附加元件。

## 前提條件

要使用這個附加元件，您需要：

1. 正在運行的 Home Assistant 實例（Home Assistant OS、Supervised 或 Container）
2. Tailscale 帳戶

如果您還沒有 Tailscale 帳戶，可以在安裝過程中創建一個。對於個人和業餘項目，Tailscale 提供免費使用，單個用戶帳戶最多支持 100 個客戶端/設備。

可以使用您的 Google、Microsoft 或 GitHub 帳戶在以下 URL 註冊：
[https://login.tailscale.com/start](https://login.tailscale.com/start)

## 安裝方法

### 方法 1：使用 Home Assistant 附加元件

1. **添加 Home Assistant 社區附加元件存儲庫**（如果您尚未添加）：
   - 在 Home Assistant 中，導航到 **Supervisor** > **附加元件商店** > 右上角的三點菜單 > **存儲庫**
   - 添加以下 URL：`https://github.com/hassio-addons/repository`
   - 點擊 **添加**，然後點擊 **關閉**

2. **安裝 Tailscale (Go) 附加元件**：
   - 在附加元件商店中找到 "Tailscale (Go)" 附加元件
   - 點擊 "Tailscale (Go)" 附加元件卡片
   - 點擊 **安裝** 按鈕
   - 等待安裝完成

3. **啟動 Tailscale 附加元件**：
   - 安裝完成後，點擊 **啟動** 按鈕
   - 檢查 Tailscale 附加元件的日誌，確保一切正常

4. **完成 Tailscale 驗證**：
   - 點擊 **打開網頁 UI** 按鈕，完成驗證並將您的 Home Assistant 實例與您的 Tailscale 帳戶連接
   - **注意**：有些瀏覽器可能無法完成此步驟。建議使用 Chrome 瀏覽器在桌面或筆記本電腦上完成此步驟。

### 方法 2：使用 Docker

如果您想在非 Home Assistant 環境中使用，或者想要更多控制權，可以使用 Docker：

#### 基本安裝

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

#### 使用 Docker Compose

```bash
# 運行 Docker Compose
docker-compose up -d
```

#### 針對特定平台優化的安裝腳本

可以使用針對您的特定平台和架構優化的腳本：

- **macOS ARM (Apple Silicon)**：使用 `docker-build-mac-arm.sh` 和 `docker-run-mac-arm.sh`
- **macOS x86 (Intel)**：使用 `docker-build-mac-x86.sh` 和 `docker-run-mac-x86.sh`
- **Linux ARM**：使用 `docker-build-linux-arm.sh` 和 `docker-run-linux-arm.sh`
- **Linux x86**：使用 `docker-build-linux-x86.sh` 和 `docker-run-linux-x86.sh`
- **Windows ARM**：使用 `docker-build-win-arm.bat` 和 `docker-run-win-arm.bat`
- **Windows x86**：使用 `docker-build-win-x86.bat` 和 `docker-run-win-x86.bat`

## 升級

當有新版本可用時，Home Assistant 會通知您。您可以通過以下步驟升級 Tailscale 附加元件：

1. 在 Home Assistant 中，導航到 **Supervisor** > **附加元件**
2. 找到 "Tailscale (Go)" 附加元件，然後點擊它
3. 如果有更新可用，您會看到一個 **更新** 按鈕
4. 點擊 **更新** 按鈕，然後等待升級完成

如果使用 Docker 方式安裝，可以通過重新構建映像並重新啟動容器來升級：

```bash
# 拉取最新代碼
git pull

# 重新構建映像
docker build -t tailscale-ha .

# 停止並移除舊容器
docker stop tailscale-ha
docker rm tailscale-ha

# 啟動新容器
./docker-run.sh
```

## 卸載

如果您需要卸載 Tailscale 附加元件，請按照以下步驟操作：

1. 在 Home Assistant 中，導航到 **Supervisor** > **附加元件**
2. 找到 "Tailscale (Go)" 附加元件，然後點擊它
3. 點擊 **卸載** 按鈕

對於 Docker 安裝，可以停止並移除容器：

```bash
docker stop tailscale-ha
docker rm tailscale-ha
```

**重要提示**：卸載附加元件將移除所有本地配置資料。如果您想保留配置，請考慮先備份配置目錄。

## 後續步驟

安裝並配置 Tailscale 附加元件後，您可以：

1. 配置 Tailscale 設置（請參閱 [配置指南](configuration.md)）
2. 學習如何使用 Tailscale 遠程訪問您的 Home Assistant（請參閱 [使用指南](usage.md)）
3. 探索高級功能，例如配置出口節點或子網路由

如果您在安裝過程中遇到問題，請參閱 [故障排除指南](troubleshooting.md)。 
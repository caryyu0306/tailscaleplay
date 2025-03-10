# Tailscale (Go 版本)

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
[![License][license-shield]](LICENSE.md)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

[![Github Actions][github-actions-shield]][github-actions]
![Project Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]

[![Discord][discord-shield]][discord]
[![Community Forum][forum-shield]][forum]

[![Sponsor Frenck via GitHub Sponsors][github-sponsors-shield]][github-sponsors]

[![Support Frenck on Patreon][patreon-shield]][patreon]

零配置 VPN，用於建立安全網絡的 Go 語言實現版本。

## 關於

這是 Tailscale 附加元件的 Go 語言重寫版本。

Tailscale 是一個零配置 VPN，幾分鐘內就可以安裝在任何設備上。

在您的伺服器、電腦和雲實例之間創建一個安全網絡。
即使被防火牆或子網分隔，Tailscale 也能正常工作。Tailscale
為您管理防火牆規則，並可以從任何地方使用。

[:books: 閱讀完整的附加元件文檔](docs)

## 特點

- 零配置 VPN，幾分鐘內在您的設備上安裝
- 安全連接：即使被防火牆或子網分隔，Tailscale 也能正常工作
- 防火牆管理：Tailscale 為您管理防火牆規則
- 遠程訪問：從任何地方安全地訪問您的設備
- 子網路由：可以選擇將您的整個網絡共享到您的 Tailscale 網絡
- 出口節點功能：可以通過您的設備路由互聯網流量
- Magic DNS：輕鬆通過名稱而不是 IP 地址訪問設備
- HTTPS 代理：為您的設備提供 TLS 證書
- Taildrop：在設備間輕鬆發送文件

## Docker 使用指南

本專案提供了簡化的 Docker 部署方式，適用於不同的操作系統和架構：

### 快速開始

1. 複製 `config.json.example` 到 `options.json` 並根據需要修改配置：
   ```bash
   cp config.json.example options.json
   ```

2. 使用通用腳本構建和運行容器：
   ```bash
   # 構建 Docker 映像
   ./docker-build.sh
   
   # 運行 Docker 容器
   ./docker-run.sh
   ```

   腳本會自動檢測您的平台和架構，並使用適當的設置。

3. 或者，使用 Docker Compose：
   ```bash
   # 生成 docker-compose.yml 文件
   ./generate-docker-compose.sh
   
   # 啟動容器
   docker-compose up -d
   ```

### 配置 Docker 容器

您可以通過修改 `options.json` 文件來配置 Tailscale 容器。腳本會自動讀取此文件並將配置轉換為相應的環境變量。

主要配置選項包括：

- `accept_dns`: 是否接受DNS設定
- `accept_routes`: 是否接受路由
- `advertise_exit_node`: 是否將節點廣告為出口節點
- `advertise_connector`: 是否將節點廣告為應用連接器
- `advertise_routes`: 要廣告的路由列表
- `funnel`: 是否啟用 Funnel 功能
- `login_server`: 登錄服務器地址
- `proxy`: 是否啟用 HTTPS 代理
- `tags`: 標籤列表
- `userspace_networking`: 是否使用用戶空間網絡

### 持續性服務（非臨時節點）

默認情況下，本專案已配置為持續性服務（非臨時節點），這意味著：

1. Tailscale 狀態會保存在持久卷中（`docker-data` 目錄）
2. 容器重啟後會保持相同的 IP 地址和身份
3. 不需要重新認證

這是通過以下設置實現的：
- `TS_STATE_DIR=/data`：將 Tailscale 狀態存儲在持久卷中
- `TS_AUTH_ONCE=true`：容器重啟時如果已經登錄，就不會強制重新登錄

### 自動登錄

您可以使用 Tailscale 認證密鑰（Auth Key）來實現自動登錄，無需手動訪問認證 URL：

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

詳細配置說明請參閱 [配置指南](docs/configuration.md) 和 [Docker 環境使用指南](docs/docker.md)。

### 平台特定腳本

如果您需要使用平台特定的腳本，我們仍然提供了以下腳本：

- **macOS ARM (Apple Silicon)**：`docker-build-mac-arm.sh` 和 `docker-run-mac-arm.sh`
- **macOS x86 (Intel)**：`docker-build-mac-x86.sh` 和 `docker-run-mac-x86.sh`
- **Linux ARM**：`docker-build-linux-arm.sh` 和 `docker-run-linux-arm.sh`
- **Linux x86**：`docker-build-linux-x86.sh` 和 `docker-run-linux-x86.sh`
- **Windows ARM**：`docker-build-win-arm.bat` 和 `docker-run-win-arm.bat`
- **Windows x86**：`docker-build-win-x86.bat` 和 `docker-run-win-x86.bat`

但我們建議使用通用腳本，它們提供了相同的功能，並且更容易維護。

## 支持

有問題嗎？

您有幾種方式來獲得解答：

- [Discord 聊天伺服器][discord] 用於附加元件支持和功能請求。
- [社區論壇][forum]。
- 加入 [Reddit subreddit][reddit] 在 [/r/tailscale][reddit]

您也可以在 GitHub 上[開啟一個問題][issue]。

## 貢獻

這是一個活躍的開源項目。我們始終歡迎希望使用
代碼或為其做出貢獻的人。

我們設立了一個單獨的文檔，其中包含我們的
[貢獻準則](.github/CONTRIBUTING.md)。

感謝您的參與！:heart_eyes:

## 作者與貢獻者

Go 語言版本由社區維護。

有關所有作者和貢獻者的完整列表，
請查看[貢獻者頁面][contributors]。

## 我們為您提供了一些 Tailscale 附加元件

想要為您的 Tailscale 實例添加更多功能嗎？

我們為 Tailscale 創建了多個附加元件。有關完整列表，請查看
我們的 [GitHub 存儲庫][repository]。

## 許可證

MIT 許可證

Copyright (c) 2021-2025 Franck Nijhof

特此免費授予任何獲得本軟件及相關文檔文件（「軟件」）副本的人
不受限制地處理本軟件的權利，包括但不限於
使用、複製、修改、合併、出版、分發、再許可和/或出售
本軟件的副本，並允許向其提供本軟件的人
這樣做，但須符合以下條件：

上述版權聲明和本許可聲明應包含在所有
軟件的副本或重要部分中。

軟件按「原樣」提供，沒有任何形式的明示或
暗示的保證，包括但不限於適銷性保證、
特定用途的適用性和非侵權性。在任何情況下都不應
作者或版權持有人對任何索賠、損害或其他
責任，無論是在合同訴訟、侵權行為或其他方面，由
於軟件或軟件的使用或其他交易而產生的、
軟件。

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-no-red.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[commits-shield]: https://img.shields.io/github/commit-activity/y/tailscale/tailscale.svg
[commits]: https://github.com/tailscale/tailscale/commits/main
[contributors]: https://github.com/tailscale/tailscale/graphs/contributors
[discord-shield]: https://img.shields.io/discord/478094546522079232.svg
[discord]: https://discord.com/invite/n3vtSwc
[forum-shield]: https://img.shields.io/badge/community-forum-brightgreen.svg
[forum]: https://forum.tailscale.com/
[github-actions-shield]: https://github.com/tailscale/tailscale/workflows/CI/badge.svg
[github-actions]: https://github.com/tailscale/tailscale/actions
[github-sponsors-shield]: https://frenck.dev/wp-content/uploads/2019/12/github_sponsor.png
[github-sponsors]: https://github.com/sponsors/frenck
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[issue]: https://github.com/tailscale/tailscale/issues
[license-shield]: https://img.shields.io/github/license/tailscale/tailscale.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2025.svg
[patreon-shield]: https://frenck.dev/wp-content/uploads/2019/12/patreon.png
[patreon]: https://www.patreon.com/frenck
[project-stage-shield]: https://img.shields.io/badge/project%20stage-experimental-yellow.svg
[reddit]: https://reddit.com/r/tailscale
[releases-shield]: https://img.shields.io/github/release/tailscale/tailscale.svg
[releases]: https://github.com/tailscale/tailscale/releases
[repository]: https://github.com/tailscale/tailscale

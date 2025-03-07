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

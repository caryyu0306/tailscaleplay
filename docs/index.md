# Tailscale 附加元件文檔 (Go 版本)

歡迎閱讀 Tailscale 附加元件 Go 版本的官方文檔。本文檔提供了關於安裝、配置和使用 Tailscale Go 版本的完整指南。

## 什麼是 Tailscale？

Tailscale 是一種零配置 VPN 服務，可簡化跨不同網絡安全連接設備和服務的過程。通過安裝 Tailscale，您可以從任何地方安全地訪問您的智能設備系統，無需複雜的網絡配置或端口轉發。

## 關於 Go 版本

這是原始 Tailscale 附加元件的 Go 語言重寫版本。它保留了原版的所有功能，同時提供了更好的性能和資源使用效率。Go 語言的並發模型和低內存占用使得此版本特別適合在資源受限的設備上運行，同時提供更好的穩定性和性能。

## 主要特點

- **零配置 VPN**：幾分鐘內在您的設備上安裝
- **安全連接**：即使被防火牆或子網分隔，Tailscale 也能正常工作
- **防火牆管理**：Tailscale 為您管理防火牆規則
- **遠程訪問**：從任何地方安全地訪問您的設備
- **子網路由**：可以選擇將您的整個網絡共享到您的 Tailscale 網絡
- **出口節點功能**：可以通過您的設備路由互聯網流量
- **Magic DNS**：輕鬆通過名稱而不是 IP 地址訪問設備
- **持續性服務**：容器重啟後保持相同的 IP 地址和身份，不需要重新認證
- **自動登錄**：支持使用認證密鑰自動登錄，無需手動訪問認證 URL

## 文檔目錄

### 入門

- [概述](overview.md) - 了解 Tailscale 及其作用
- [快速入門指南](getting_started.md) - 在 10 分鐘內設置 Tailscale
- [安裝指南](installation.md) - 詳細的安裝步驟（包括 Docker 部署選項）

### 配置和使用

- [配置指南](configuration.md) - 了解所有配置選項及其用途
- [使用指南](usage.md) - 學習如何有效地使用 Tailscale
- [Docker 環境使用指南](docker.md) - 在 Docker 環境中使用 Tailscale 的詳細說明

### 故障排除

- [常見問題](faq.md) - 常見問題和解答
- [故障排除指南](troubleshooting.md) - 解決使用 Tailscale 時可能遇到的問題

## 支持的平台

此 Go 版本支持以下平台和架構：

- macOS (x86/Intel 和 ARM/Apple Silicon)
- Linux (x86_64 和 ARM64)
- Windows (x86_64 和 ARM)
- 所有主要操作系統平台

## 關於本文檔

本文檔適用於 Tailscale 附加元件 Go 版本的最新版本。如果您發現任何錯誤或有改進建議，請在 GitHub 存儲庫上報告。

## 其他資源

- [Tailscale 官方文檔](https://tailscale.com/kb/)
- [社區論壇](https://community.home-assistant.io/) 
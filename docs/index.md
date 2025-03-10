# Tailscale Docker 容器文檔

歡迎閱讀 Tailscale Docker 容器專案的官方文檔。本文檔提供了關於配置和使用 Tailscale Docker 容器的完整指南。

## 什麼是 Tailscale？

Tailscale 是一種零配置 VPN 服務，可簡化跨不同網絡安全連接設備和服務的過程。通過安裝 Tailscale，您可以從任何地方安全地訪問您的設備和服務，無需複雜的網絡配置或端口轉發。

## 關於本專案

這是一個簡化的 Tailscale Docker 容器部署專案，提供了方便的腳本和配置。它使用官方 Tailscale Docker 映像，並添加了便捷的配置和管理腳本，使 Tailscale 在 Docker 環境中的部署和使用變得更加簡單。

## 主要特點

- **零配置 VPN**：簡單易用
- **安全連接**：即使被防火牆或子網分隔，也能正常工作
- **自動管理防火牆規則**
- **遠程訪問**：從任何地方安全地訪問您的設備
- **子網路由**：將您的整個網絡共享到您的 Tailscale 網絡
- **出口節點功能**：通過您的設備路由互聯網流量
- **Magic DNS**：通過名稱而不是 IP 地址訪問設備
- **持久性服務**：容器重啟後保持相同的 IP 地址和身份
- **自動登錄**：支持使用認證密鑰自動登錄

## 文檔目錄

### 配置和使用

- [配置指南](configuration.md) - 了解所有配置選項及其用途
- [Docker 環境使用指南](docker.md) - 在 Docker 環境中使用 Tailscale 的詳細說明
- [使用指南](usage.md) - 學習如何有效地使用 Tailscale

### 故障排除

- [常見問題](faq.md) - 常見問題和解答
- [故障排除指南](troubleshooting.md) - 解決使用 Tailscale 時可能遇到的問題

## 快速開始

1. 複製 `config.json.example` 到 `options.json` 並根據需要修改配置
2. 運行 Tailscale 容器：
   ```bash
   ./tailscale.sh run
   ```
3. 或使用認證密鑰實現自動登錄：
   ```bash
   ./tailscale.sh run --authkey=tskey-auth-xxxxxxxxxxxxxxxx
   ```

詳細的設置和配置步驟，請參閱 [Docker 環境使用指南](docker.md)。

## 支持的平台

本專案支持所有能夠運行 Docker 的平台，包括：

- macOS (x86/Intel 和 ARM/Apple Silicon)
- Linux (x86_64 和 ARM64)
- Windows (x86_64 和 ARM)

## 其他資源

- [Tailscale 官方文檔](https://tailscale.com/kb/)
- [Tailscale Docker 映像文檔](https://tailscale.com/kb/1282/docker) 
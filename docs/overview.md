# Tailscale Home Assistant 附加元件概述

## 什麼是 Tailscale？

Tailscale 是一種零配置 VPN（虛擬私人網絡）服務，可簡化跨不同網絡安全連接設備和服務的過程。它使用開源的 WireGuard 協議啟用加密的點對點連接，這意味著只有您私人網絡上的設備可以相互通信。

與傳統 VPN 不同，傳統 VPN 通過中央網關服務器隧道傳輸所有網絡流量，Tailscale 創建一個點對點網格網絡（稱為 tailnet）。不過，您仍然可以通過出口節點（exit node）路由所有流量，像傳統 VPN 一樣使用 Tailscale。

### Tailscale 的主要優勢

1. **簡化設置**：
   - 無需複雜的網絡配置，幾分鐘內即可部署
   - 無需端口轉發或複雜的防火牆規則
   - 跨防火牆和 NAT（網絡地址轉換）無縫工作

2. **安全與隱私**：
   - 基於現代、經過驗證的技術和最佳實踐，如端到端加密和零信任架構
   - 使用 WireGuard，這是一種以安全性和性能著稱的最先進 VPN 協議
   - 支援訪問控制策略和 tailnet 鎖定等安全功能

3. **可擴展性和適應性**：
   - 靈活的架構，可隨著組織需求的增長而無縫擴展
   - 分佈式架構意味著添加新設備或用戶不會造成瓶頸

## Home Assistant Tailscale 附加元件

這個 Home Assistant 社區附加元件讓您能夠在 Home Assistant 實例上安裝和配置 Tailscale，從而創建一個安全的網絡連接，使您可以從任何地方安全地訪問您的 Home Assistant 和本地網絡。

### 主要功能

- **零配置 VPN**：幾分鐘內在您的 Home Assistant 實例上安裝
- **安全連接**：即使被防火牆或子網分隔，Tailscale 也能正常工作
- **防火牆管理**：Tailscale 為您管理防火牆規則
- **遠程訪問**：從任何地方安全地訪問您的 Home Assistant 實例
- **子網路由**：可以選擇將您的整個家庭網絡共享到您的 Tailscale 網絡
- **出口節點功能**：可以通過您的 Home Assistant 實例路由互聯網流量
- **Magic DNS**：輕鬆通過名稱而不是 IP 地址訪問設備
- **HTTPS 代理**：為您的 Home Assistant 實例提供 TLS 證書
- **Taildrop**：在設備間輕鬆發送文件

### 支持的架構

- aarch64
- amd64
- armv7
- i386（不支持）
- armhf（不支持）

## 許可證

本項目使用 MIT 許可證。 
# Tailscale 附加元件配置指南

本文檔介紹了 Tailscale 附加元件的配置選項。適當的配置可以幫助您充分利用 Tailscale 功能。

## 基本配置

Tailscale 附加元件本身的配置選項相對較少。大部分 Tailscale 網絡配置都是通過 Tailscale 的網頁界面完成的：[https://login.tailscale.com/](https://login.tailscale.com/)

附加元件公開了"出口節點"功能，您可以從 Tailscale 帳戶啟用該功能。此外，如果 Supervisor 管理您的網絡（這是默認設置），附加元件還將向 Tailscale 通告您所有支持的接口上子網的路由。

考慮禁用密鑰過期以避免失去與您的設備的連接。有關更多信息，請參閱 [密鑰過期](https://tailscale.com/kb/1028/key-expiry)。

## YAML 配置參考

以下是附加元件配置選項的完整參考。您可以在添加元件界面的"配置"選項卡中修改這些設置。

```yaml
accept_dns: true
accept_routes: true
advertise_exit_node: true
advertise_connector: true
advertise_routes:
  - 192.168.1.0/24
  - fd12:3456:abcd::/64
funnel: false
log_level: info
login_server: "https://controlplane.tailscale.com"
proxy: false
proxy_and_funnel_port: 443
snat_subnet_routes: true
stateful_filtering: false
tags:
  - tag:example
  - tag:tailscale
taildrop: true
userspace_networking: true
```

> **注意**：這些配置選項中的一些也可以在通過網頁 UI 訪問的 Tailscale 網頁界面上使用，但它們在那裡是只讀的。您不能通過網頁 UI 更改它們，因為在重新啟動附加元件時，所有在那裡進行的更改都會丟失。

## 配置選項詳解

### 選項：`accept_dns`

如果您在此設備上遇到 MagicDNS 問題並希望禁用它，可以使用此選項。

未設置時，此選項默認啟用。

如果您在與此附加元件相同的機器上運行 Pi-hole 或 AdGuard 等服務，MagicDNS 可能會導致問題。在這種情況下，禁用 `accept_dns` 將會有所幫助。您仍然可以在網絡上的其他設備上利用 MagicDNS，方法是在 Pi-hole 或 AdGuard 中添加 `100.100.100.100` 作為 DNS 服務器。

### 選項：`accept_routes`

此選項允許您接受 tailnet 中其他節點通告的子網路由。

更多信息：[子網路由器](https://tailscale.com/kb/1019/subnets)

未設置時，此選項默認啟用。

### 選項：`advertise_exit_node`

此選項允許您將此 Tailscale 實例通告為出口節點。

通過將網絡上的設備設置為出口節點，您可以根據需要通過它路由所有公共互聯網流量，就像消費者 VPN 一樣。

更多信息：[出口節點](https://tailscale.com/kb/1103/exit-nodes)

未設置時，此選項默認啟用。

### 選項：`advertise_connector`

此選項允許您將此 Tailscale 實例通告為應用連接器。

當您使用應用連接器時，您可以指定希望在 tailnet 上訪問的應用程序以及這些應用程序的域名。針對該應用程序的任何流量都會強制通過 tailnet 到運行應用連接器的節點，然後再到目標域名。這對於應用程序具有可以連接的 IP 地址允許列表的情況很有用：運行應用連接器的節點的 IP 地址可以添加到允許列表中，tailnet 上的所有節點都將使用該 IP 地址進行流量出口。

更多信息：[應用連接器](https://tailscale.com/kb/1281/app-connectors)

未設置時，此選項默認啟用。

### 選項：`advertise_routes`

此選項允許您將路由通告到子網（可在您的設備連接的網絡上訪問）到 tailnet 上的其他客戶端。

通過在列表中添加子網路由的 IP 地址和掩碼，您可以使這些子網上的設備在您的 tailnet 中可訪問。

如果要禁用此選項，請在配置中指定一個空列表（YAML 中的 `[]`）。

更多信息：[子網路由器](https://tailscale.com/kb/1019/subnets)

未設置時，默認情況下，附加元件將在所有支持的接口上通告到您的子網的路由。

### 選項：`funnel`

這需要啟用 Tailscale 代理。

**重要**：請同時參閱本文檔的"選項：`proxy`"部分，了解配置中必要的配置更改！

未設置時，此選項默認禁用。

使用 Tailscale Funnel 功能，您可以使用您的 Tailscale 域名（如 `https://yourdevice.tail1234.ts.net`）從更廣泛的互聯網訪問您的設備，甚至從**沒有安裝 Tailscale VPN 客戶端**的設備（例如，一般的手機、平板電腦和筆記本電腦）。

**客戶端** → _互聯網_ → **Tailscale Funnel**（TCP 代理）→ _VPN_ → **Tailscale 代理**（HTTPS 代理）→ **設備**（HTTP 網絡服務器）

如果沒有 Tailscale Funnel 功能，您只能在設備（例如，手機、平板電腦和筆記本電腦）連接到 Tailscale VPN 時訪問您的設備，不會有互聯網 → VPN TCP 代理用於 HTTPS 通信。

更多信息：[Tailscale Funnel](https://tailscale.com/kb/1223/funnel)

### 選項：`log_level`

可選地在附加元件的日誌中啟用 tailscaled 調試消息。僅在排除故障時打開它，因為 Tailscale 的守護進程相當嘮叨。如果 `log_level` 設置為 `info` 或更低嚴重級別，附加元件還會選擇退出客戶端日誌上傳到 log.tailscale.io。

選項 `log_level` 控制附加元件的日誌輸出級別，可以更改為更多或更少詳細的級別，這在您處理未知問題時可能很有用。可能的值有：

- `trace`：顯示每個細節，如所有調用的內部函數。
- `debug`：顯示詳細的調試信息。
- `info`：正常（通常）有趣的事件。
- `notice`：正常但重要的事件。
- `warning`：不是錯誤的例外情況。
- `error`：不需要立即採取行動的運行時錯誤。
- `fatal`：出現嚴重錯誤。附加元件變得不可用。

請注意，每個級別會自動包含更嚴重級別的日誌消息，例如，`debug` 也會顯示 `info` 消息。默認情況下，`log_level` 設置為 `info`，這是推薦的設置，除非您正在排除故障。

### 選項：`login_server`

此選項允許您指定自定義控制服務器，而不是默認的 (`https://controlplane.tailscale.com`)。如果您正在運行自己的 Tailscale 控制服務器，例如自託管的 [Headscale](https://github.com/juanfont/headscale) 實例，這將非常有用。

### 選項：`proxy`

未設置時，此選項默認禁用。

Tailscale 可以為您的設備提供 TLS 證書，在您的 tailnet 域內使用。

這可以防止瀏覽器警告您的 HTTP URL 看起來未加密（瀏覽器不知道 Tailscale 節點之間的連接是用端到端加密保護的）。

更多信息：[啟用 HTTPS](https://tailscale.com/kb/1153/enabling-https)

### 選項：`proxy_and_funnel_port`

此選項允許您配置 Tailscale 代理和 Funnel 功能在 tailnet 上可訪問的端口（如果啟用了 Tailscale 代理），以及可選地在互聯網上（如果還啟用了 Tailscale Funnel）。

Tailscale 只允許端口號 443、8443 和 10000。

未設置時，默認使用端口號 443。

### 選項：`snat_subnet_routes`

此選項允許子網設備看到源自子網路由器的流量，這簡化了路由配置。

未設置時，此選項默認啟用。

為了支持高級[站點到站點網絡](https://tailscale.com/kb/1214/site-to-site)（例如穿越多個網絡），您可以禁用此功能，並按照[站點到站點網絡](https://tailscale.com/kb/1214/site-to-site)指南中的步驟操作（注意：附加元件已經為您處理了"IP 地址轉發"和"將 MSS 限制到 MTU"）。

**注意**：只有在完全理解含義的情況下才禁用此選項。如果保留真實源 IP 地址對您的用例不是至關重要的，請保持啟用狀態。

### 選項：`stateful_filtering`

此選項在包轉發節點（出口節點、子網路由器和應用連接器）上啟用有狀態包過濾，僅允許現有出站連接的返回包。不屬於現有連接的入站包將被丟棄。

未設置時，此選項默認禁用。

### 選項：`tags`

此選項允許您為此 Tailscale 實例指定特定標籤。它們需要以 `tag:` 開頭。

更多信息：[標籤](https://tailscale.com/kb/1068/tags)

### 選項：`taildrop`

此附加元件支持 [Tailscale 的 Taildrop](https://tailscale.com/taildrop) 功能，允許您從其他 Tailscale 設備向設備發送文件。

未設置時，此選項默認啟用。

接收到的文件存儲在 `/share/taildrop` 目錄中。

### 選項：`userspace_networking`

附加元件使用[用戶空間網絡模式](https://tailscale.com/kb/1112/userspace-networking)使您的設備（以及可選的本地子網）在您的 tailnet 中可訪問。

未設置時，此選項默認啟用。

如果您需要從設備訪問 tailnet 上的其他客戶端，請禁用用戶空間網絡模式，這將在您的主機上創建一個 `tailscale0` 網絡接口。要能夠不僅用它們的 tailnet IP 地址，還用它們的 tailnet 名稱來尋址這些客戶端，您還必須配置 DNS 選項。

## 網絡

### 端口：`41641/udp`

用於 WireGuard 和點對點流量的 UDP 監聽端口。

如果您發現 Tailscale 無法建立與某些設備的點對點連接（通常在 CGNAT 網絡後面），請使用此選項（和路由器端口轉發）。您可以用 `tailscale ping <hostname-or-ip>` 測試連接。

未設置時，默認使用自動選擇的端口。 
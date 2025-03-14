# Tailscale Docker 容器故障排除指南

本文檔提供解決使用 Tailscale Docker 容器時可能遇到的常見問題的步驟。

## 診斷工具

在開始故障排除之前，以下診斷工具和資源可能會有幫助：

1. **容器日誌**：
   ```bash
   docker logs tailscale-ha
   ```

2. **Tailscale 狀態**：
   ```bash
   docker exec tailscale-ha tailscale status
   ```

3. **Tailscale 管理控制台**：
   - 前往 [https://login.tailscale.com](https://login.tailscale.com)
   - 檢查連接的設備、它們的狀態和 IP 地址

## 常見問題及解決方案

### 問題：容器無法啟動

**症狀**：Docker 容器無法啟動，或啟動後立即退出。

**可能的解決方案**：
1. 檢查 Docker 日誌：
   ```bash
   docker logs tailscale-ha
   ```

2. 確保設備有 `/dev/net/tun` 設備：
   ```bash
   ls -l /dev/net/tun
   ```
   如果不存在，您可能需要加載 tun 模塊：
   ```bash
   sudo modprobe tun
   ```

3. 確保容器有正確的權限：
   ```bash
   docker run --cap-add=NET_ADMIN --cap-add=NET_RAW ...
   ```

4. 檢查 `docker-data` 目錄的權限：
   ```bash
   ls -la ./docker-data
   ```
   確保目錄可寫入。

### 問題：容器啟動，但 Tailscale 無法連接

**症狀**：容器啟動成功，但 Tailscale 無法連接到網絡。

**可能的解決方案**：
1. 檢查網絡連接是否正常，特別是 UDP 端口 41641 是否開放：
   ```bash
   nc -vuz login.tailscale.com 41641
   ```

2. 驗證防火牆設置是否阻止了 Tailscale 的連接。

3. 如果使用認證密鑰，確保密鑰有效且未過期。

4. 嘗試重新登錄：
   ```bash
   docker exec tailscale-ha tailscale login
   ```

### 問題：Tailscale 連接成功，但無法訪問子網

**症狀**：Tailscale 顯示為已連接，但無法通過它訪問已廣告的子網。

**可能的解決方案**：
1. 確保在 `options.json` 中正確配置了 `advertise_routes`。

2. 確保您在 Tailscale 管理控制台中批准了子網路由。

3. 確保 `snat_subnet_routes` 設置正確（通常應該是 `true`）。

4. 檢查容器的 IP 轉發是否啟用：
   ```bash
   docker exec tailscale-ha sysctl net.ipv4.ip_forward
   ```
   應該輸出 `net.ipv4.ip_forward = 1`。

5. 在其他設備上確保啟用了接受路由選項：
   ```bash
   tailscale up --accept-routes
   ```

### 問題：無法在容器內使用 Tailscale 命令

**症狀**：嘗試在容器內運行 `tailscale` 命令時出錯。

**可能的解決方案**：
1. 在執行命令時，確保以正確的用戶運行：
   ```bash
   docker exec tailscale-ha tailscale status
   ```

2. 檢查 LocalAPI 套接字是否存在：
   ```bash
   docker exec tailscale-ha ls -l /var/run/tailscale/tailscaled.sock
   ```

3. 重啟容器可能會解決一些短暫的問題：
   ```bash
   docker restart tailscale-ha
   ```

### 問題：容器重啟後 Tailscale IP 地址改變

**症狀**：每次容器重啟後，設備獲得一個新的 Tailscale IP 地址。

**可能的解決方案**：
1. 確保正確掛載了持久存儲卷：
   ```bash
   docker inspect tailscale-ha | grep -A 10 Mounts
   ```
   確保 `docker-data` 目錄正確掛載到容器的 `/data` 目錄。

2. 確保設置了 `TS_STATE_DIR=/data` 環境變量。

3. 確保設置了 `TS_AUTH_ONCE=true` 環境變量。

4. 如果您使用的是認證密鑰，確保沒有設置為臨時節點（不要在密鑰後面添加 `?ephemeral=true`）。

### 問題：Taildrop 功能無法使用

**症狀**：無法使用 Taildrop 功能發送或接收文件。

**可能的解決方案**：
1. 確保在 `options.json` 中啟用了 `taildrop` 選項。

2. 確保 `docker-share` 目錄已正確掛載到容器的 `/share` 目錄：
   ```bash
   docker inspect tailscale-ha | grep -A 10 Mounts
   ```

3. 檢查 `docker-share` 目錄的權限：
   ```bash
   ls -la ./docker-share
   ```
   確保目錄可寫入。

4. 在 Tailscale 管理控制台中確認 Taildrop 權限設置是否正確。

## 進階故障排除

### 收集診斷信息

要收集完整的診斷信息以協助故障排除，可以運行：

```bash
docker exec tailscale-ha tailscale bugreport
```

這將生成一個包含診斷信息的報告，可以與支持團隊共享。

### 重置 Tailscale 狀態

如果遇到持續的問題，可以嘗試完全重置 Tailscale 狀態：

1. 停止容器：
   ```bash
   docker stop tailscale-ha
   ```

2. 備份並刪除現有狀態：
   ```bash
   cp -r docker-data docker-data.bak
   rm -rf docker-data/*
   ```

3. 重新啟動容器：
   ```bash
   docker start tailscale-ha
   ```
   或者使用腳本重新運行：
   ```bash
   ./tailscale.sh run
   ```

4. 重新進行身份驗證。

### 網絡連接問題

如果懷疑是網絡連接問題，可以檢查：

1. 確保端口 41641/UDP 開放且可從互聯網訪問：
   ```bash
   # 在容器中檢查
   docker exec tailscale-ha netstat -tulpn | grep 41641
   
   # 在主機上檢查
   netstat -tulpn | grep 41641
   ```

2. 檢查防火牆規則是否允許 UDP 流量。

3. 如果在公司網絡或受限網絡環境中，可能需要使用 DERP 中繼。這是 Tailscale 的默認行為，但可能需要確保沒有阻止相關流量。

### 問題：Docker 實驗性功能錯誤

**症狀**：執行 `./tailscale.sh run` 時出現以下錯誤：
```
"--platform" is only supported on a Docker daemon with experimental features enabled
```

**原因**：腳本使用了 Docker 的 `--platform` 參數來指定容器的運行平台，但您的 Docker daemon 沒有啟用實驗性功能。

**解決方案一：啟用 Docker daemon 的實驗性功能**

1. 編輯或創建 Docker daemon 配置文件：
   ```bash
   sudo mkdir -p /etc/docker
   sudo nano /etc/docker/daemon.json
   ```

2. 在文件中添加以下內容：
   ```json
   {
     "experimental": true
   }
   ```

3. 保存文件並重啟 Docker 服務：
   ```bash
   sudo systemctl restart docker
   ```

4. 重新執行 tailscale.sh 腳本：
   ```bash
   ./tailscale.sh run
   ```

**解決方案二：修改 tailscale.sh 腳本，移除 --platform 參數**

這是一個更簡單的解決方案，特別是如果您的系統架構與容器架構相同：

1. 編輯 tailscale.sh 文件：
   ```bash
   nano tailscale.sh
   ```

2. 找到 docker run 命令（大約在第 300 行左右），移除 `--platform=${PLATFORM}` 這一行。修改前：
   ```bash
   docker run -d --name ${CONTAINER_NAME} \
     --platform=${PLATFORM} \
     --hostname ${CONTAINER_NAME} \
     --restart unless-stopped \
     ...
   ```

   修改後：
   ```bash
   docker run -d --name ${CONTAINER_NAME} \
     --hostname ${CONTAINER_NAME} \
     --restart unless-stopped \
     ...
   ```

3. 如果您使用 `compose` 命令，也需要修改腳本中生成 docker-compose.yml 的部分，移除 `platform: $PLATFORM` 行。

## 更多幫助

如果以上解決方案無法解決您的問題，您可以：

1. 訪問 [Tailscale 官方文檔](https://tailscale.com/kb/)
2. 查看 [Tailscale 論壇](https://forum.tailscale.com/)
3. 在 GitHub 上提交問題 
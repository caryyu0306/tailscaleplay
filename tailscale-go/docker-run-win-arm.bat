@echo off
setlocal

REM 設置變量
set IMAGE_NAME=tailscale-ha
set TAG=win-arm
set CONTAINER_NAME=tailscale-ha

REM 創建數據目錄
if not exist docker-data mkdir docker-data
if not exist docker-share\taildrop mkdir docker-share\taildrop

REM 檢查容器是否已存在
docker ps -a -q -f name=%CONTAINER_NAME% > temp.txt
set /p CONTAINER_ID=<temp.txt
del temp.txt

if defined CONTAINER_ID (
    echo 停止並移除現有容器...
    docker stop %CONTAINER_NAME%
    docker rm %CONTAINER_NAME%
)

REM 運行容器（後台模式）
echo 啟動 %CONTAINER_NAME% 容器...
docker run -d --name %CONTAINER_NAME% ^
  --platform=linux/arm64 ^
  --hostname %CONTAINER_NAME% ^
  --restart unless-stopped ^
  --cap-add NET_ADMIN ^
  --cap-add NET_RAW ^
  --device /dev/net/tun ^
  -v %cd%\docker-data:/data ^
  -v %cd%\docker-share:/share ^
  -p 41641:41641/udp ^
  %IMAGE_NAME%:%TAG%

echo 容器已啟動！
echo 等待 Tailscale 啟動...

REM 等待 Tailscale 啟動
set MAX_ATTEMPTS=30
set ATTEMPT=0
set TAILSCALE_READY=false

:WAIT_LOOP
if %ATTEMPT% geq %MAX_ATTEMPTS% goto :END_WAIT
set /a ATTEMPT+=1

REM 獲取容器日誌
docker logs %CONTAINER_NAME% > tailscale_logs.txt 2>&1

REM 檢查是否已經啟動
findstr /C:"Tailscale 已啟動" tailscale_logs.txt > nul
if %ERRORLEVEL% equ 0 (
    set TAILSCALE_READY=true
    goto :END_WAIT
)

REM 檢查是否包含舊格式的認證 URL
findstr /C:"To authenticate, visit:" tailscale_logs.txt > nul
if %ERRORLEVEL% equ 0 (
    REM 提取並顯示認證 URL
    echo.
    echo ========================================================
    echo 認證 URL: 
    findstr /C:"To authenticate, visit:" tailscale_logs.txt
    findstr /V /C:"To authenticate, visit:" tailscale_logs.txt | findstr /C:"https://" > auth_url.txt
    type auth_url.txt
    echo ========================================================
    echo.
    
    REM 顯示 QR 碼
    findstr /C:"█" tailscale_logs.txt
    
    set TAILSCALE_READY=true
    goto :END_WAIT
)

REM 檢查是否包含新格式的認證 URL (control: AuthURL is)
findstr /C:"control: AuthURL is" tailscale_logs.txt > nul
if %ERRORLEVEL% equ 0 (
    REM 提取並顯示認證 URL
    echo.
    echo ========================================================
    echo 認證 URL:
    findstr /C:"control: AuthURL is" tailscale_logs.txt
    echo ========================================================
    echo.
    
    REM 嘗試生成 QR 碼 (如果有)
    findstr /C:"█" tailscale_logs.txt > qr_code.txt
    if exist qr_code.txt (
        type qr_code.txt
    ) else (
        echo 沒有找到 QR 碼，請使用上面的 URL 進行認證
    )
    
    set TAILSCALE_READY=true
    goto :END_WAIT
)

echo 等待 Tailscale 啟動 (嘗試 %ATTEMPT%/%MAX_ATTEMPTS%)...
timeout /t 1 > nul
goto :WAIT_LOOP

:END_WAIT
del tailscale_logs.txt
if exist auth_url.txt del auth_url.txt
if exist qr_code.txt del qr_code.txt

if "%TAILSCALE_READY%"=="true" (
    echo Tailscale 已成功啟動！
    
    REM 顯示 Tailscale 狀態
    echo.
    echo Tailscale 狀態：
    docker exec %CONTAINER_NAME% tailscale --socket=/tmp/tailscale/tailscaled.sock status
    if %ERRORLEVEL% neq 0 echo 無法獲取 Tailscale 狀態，請檢查容器日誌
) else (
    echo Tailscale 啟動超時，請檢查容器日誌：
    echo docker logs -f %CONTAINER_NAME%
)

endlocal 
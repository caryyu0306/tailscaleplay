@echo off
setlocal

REM 設置變量
set IMAGE_NAME=tailscale-ha
set TAG=win-x86

REM 確保 Docker 使用 amd64 平台構建
echo 構建 Windows x86 兼容的 Docker 映像 %IMAGE_NAME%:%TAG%...
docker build --platform=linux/amd64 -t %IMAGE_NAME%:%TAG% -f Dockerfile.win-x86 .

echo 構建完成！
echo 您可以使用以下命令運行容器：
echo docker run -d --name tailscale-ha ^
echo   --restart unless-stopped ^
echo   --cap-add NET_ADMIN ^
echo   --cap-add NET_RAW ^
echo   --device /dev/net/tun ^
echo   -v %cd%\docker-data:/data ^
echo   -v %cd%\docker-share:/share ^
echo   -p 41641:41641/udp ^
echo   %IMAGE_NAME%:%TAG%

REM 創建 docker-compose-win-x86.yml 文件
echo version: '3' > docker-compose-win-x86.yml
echo. >> docker-compose-win-x86.yml
echo services: >> docker-compose-win-x86.yml
echo   tailscale-ha: >> docker-compose-win-x86.yml
echo     image: %IMAGE_NAME%:%TAG% >> docker-compose-win-x86.yml
echo     platform: linux/amd64 >> docker-compose-win-x86.yml
echo     container_name: tailscale-ha >> docker-compose-win-x86.yml
echo     restart: unless-stopped >> docker-compose-win-x86.yml
echo     cap_add: >> docker-compose-win-x86.yml
echo       - NET_ADMIN >> docker-compose-win-x86.yml
echo       - NET_RAW >> docker-compose-win-x86.yml
echo     devices: >> docker-compose-win-x86.yml
echo       - /dev/net/tun >> docker-compose-win-x86.yml
echo     volumes: >> docker-compose-win-x86.yml
echo       - ./docker-data:/data >> docker-compose-win-x86.yml
echo       - ./docker-share:/share >> docker-compose-win-x86.yml
echo     ports: >> docker-compose-win-x86.yml
echo       - "41641:41641/udp" >> docker-compose-win-x86.yml

echo 已創建 docker-compose-win-x86.yml 文件，您可以使用以下命令運行：
echo docker-compose -f docker-compose-win-x86.yml up -d

endlocal 
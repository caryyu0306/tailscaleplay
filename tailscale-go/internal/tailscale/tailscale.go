package tailscale

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/yourusername/tailscale/internal/config"
)

// 模擬模式設置
var simulationMode bool

// SetSimulationMode 設置模擬模式
func SetSimulationMode(enabled bool) {
	simulationMode = enabled
	log.Printf("模擬模式已%s", map[bool]string{true: "啟用", false: "禁用"}[enabled])
}

// Tailscale 代表 Tailscale 客戶端
type Tailscale struct {
	cfg       *config.Config
	cmd       *exec.Cmd
	authURL   string
	status    string
	ipAddress string
	mu        sync.Mutex
	ctx       context.Context
	cancel    context.CancelFunc
}

// New 創建一個新的 Tailscale 客戶端
func New(cfg *config.Config) (*Tailscale, error) {
	ctx, cancel := context.WithCancel(context.Background())
	return &Tailscale{
		cfg:    cfg,
		status: "停止",
		ctx:    ctx,
		cancel: cancel,
	}, nil
}

// Start 啟動 Tailscale 服務
func (t *Tailscale) Start() error {
	t.mu.Lock()
	defer t.mu.Unlock()

	if t.cmd != nil {
		return fmt.Errorf("Tailscale 已經在運行中")
	}

	// 如果是模擬模式，不實際啟動 tailscaled
	if simulationMode {
		log.Println("模擬模式：不實際啟動 tailscaled")
		t.status = "模擬運行中"
		t.ipAddress = "100.100.100.100"
		t.authURL = "https://login.tailscale.com/a/1234567890"
		return nil
	}

	// 檢查 tailscaled 是否存在
	tailscaledPath, err := exec.LookPath("tailscaled")
	if err != nil {
		return fmt.Errorf("找不到 tailscaled: %v", err)
	}
	log.Printf("找到 tailscaled: %s", tailscaledPath)

	// 使用 tmpfs 目錄
	tmpDir := "/tmp/tailscale"
	if err := os.MkdirAll(tmpDir, 0755); err != nil {
		return fmt.Errorf("創建臨時目錄失敗: %v", err)
	}

	// 確保目錄存在
	if err := os.MkdirAll(t.cfg.StateDir, 0755); err != nil {
		return fmt.Errorf("創建狀態目錄失敗: %v", err)
	}
	if err := os.MkdirAll(t.cfg.TaildropDir, 0755); err != nil {
		return fmt.Errorf("創建 Taildrop 目錄失敗: %v", err)
	}

	// 確保 socket 文件不存在
	socketPath := filepath.Join(tmpDir, "tailscaled.sock")
	if err := os.Remove(socketPath); err != nil && !os.IsNotExist(err) {
		log.Printf("移除舊的 socket 文件時出錯: %v", err)
	}

	// 構建 tailscaled 命令
	args := []string{
		"--state", filepath.Join(t.cfg.StateDir, "tailscaled.state"),
		"--socket", socketPath,
	}

	// 添加 Taildrop 目錄
	if *t.cfg.Taildrop {
		args = append(args, "--tun=userspace-networking")
		args = append(args, "--socks5-server=localhost:1055")
		args = append(args, fmt.Sprintf("--outbound-http-proxy-listen=localhost:%s", t.cfg.ProxyAndFunnelPort))
	}

	// 添加用戶空間網絡
	if *t.cfg.UserspaceNetworking {
		args = append(args, "--tun=userspace-networking")
	}

	// 添加日誌級別
	if t.cfg.LogLevel != "info" {
		args = append(args, "--verbose=1")
	}

	// 創建並啟動 tailscaled 進程
	log.Printf("啟動 tailscaled: %s %s", tailscaledPath, strings.Join(args, " "))
	t.cmd = exec.CommandContext(t.ctx, tailscaledPath, args...)
	t.cmd.Stdout = os.Stdout
	t.cmd.Stderr = os.Stderr

	if err := t.cmd.Start(); err != nil {
		return fmt.Errorf("啟動 tailscaled 失敗: %v", err)
	}

	// 等待 tailscaled 啟動
	log.Println("等待 tailscaled 啟動...")
	time.Sleep(2 * time.Second)

	// 配置 tailscale
	if err := t.configure(); err != nil {
		// 不要在這裡調用 t.Stop()，因為它可能導致死鎖
		t.cmd = nil
		return fmt.Errorf("配置 tailscale 失敗: %v", err)
	}

	// 啟動狀態監控
	go t.monitorStatus()

	t.status = "運行中"
	return nil
}

// Stop 停止 Tailscale 服務
func (t *Tailscale) Stop() error {
	// 避免死鎖，先檢查是否已經鎖定
	if t.cmd == nil {
		return nil
	}

	// 如果是模擬模式，不實際停止 tailscaled
	if simulationMode {
		log.Println("模擬模式：不實際停止 tailscaled")
		t.status = "停止"
		return nil
	}

	log.Println("正在停止 Tailscale...")
	t.cancel()

	// 等待進程退出，但不要在 Start 方法中調用 Stop
	// 這裡不再使用 t.cmd.Wait()，因為它可能導致死鎖
	t.cmd = nil
	t.status = "停止"
	log.Println("Tailscale 已停止")
	return nil
}

// GetAuthURL 獲取認證 URL
func (t *Tailscale) GetAuthURL() string {
	t.mu.Lock()
	defer t.mu.Unlock()
	return t.authURL
}

// GetStatus 獲取 Tailscale 狀態
func (t *Tailscale) GetStatus() string {
	t.mu.Lock()
	defer t.mu.Unlock()
	return t.status
}

// GetIPAddress 獲取 Tailscale IP 地址
func (t *Tailscale) GetIPAddress() string {
	t.mu.Lock()
	defer t.mu.Unlock()
	return t.ipAddress
}

// 配置 tailscale
func (t *Tailscale) configure() error {
	// 如果是模擬模式，不實際配置 tailscale
	if simulationMode {
		log.Println("模擬模式：不實際配置 tailscale")
		return nil
	}

	// 檢查 tailscale 是否存在
	tailscalePath, err := exec.LookPath("tailscale")
	if err != nil {
		return fmt.Errorf("找不到 tailscale: %v", err)
	}
	log.Printf("找到 tailscale: %s", tailscalePath)

	// 使用 tmpfs 目錄
	tmpDir := "/tmp/tailscale"
	socketPath := filepath.Join(tmpDir, "tailscaled.sock")

	args := []string{
		"--socket=" + socketPath,
		"up",
		"--accept-risk=lose-ssh",
		"--reset",
		"--qr", // 添加 QR 碼選項
	}

	// 添加登錄服務器
	if t.cfg.LoginServer != "" {
		args = append(args, "--login-server="+t.cfg.LoginServer)
	}

	// 添加 DNS 設置
	if *t.cfg.AcceptDNS {
		args = append(args, "--accept-dns=true")
	} else {
		args = append(args, "--accept-dns=false")
	}

	// 添加路由設置
	if *t.cfg.AcceptRoutes {
		args = append(args, "--accept-routes=true")
	} else {
		args = append(args, "--accept-routes=false")
	}

	// 添加出口節點設置
	if *t.cfg.AdvertiseExitNode {
		args = append(args, "--advertise-exit-node")
	}

	// 添加應用連接器設置
	if *t.cfg.AdvertiseConnector {
		args = append(args, "--advertise-connector")
	}

	// 添加子網路由設置
	if len(t.cfg.AdvertiseRoutes) > 0 {
		args = append(args, "--advertise-routes="+strings.Join(t.cfg.AdvertiseRoutes, ","))
	}

	// 添加 SNAT 設置
	if *t.cfg.SNATSubnetRoutes {
		args = append(args, "--snat-subnet-routes=true")
	} else {
		args = append(args, "--snat-subnet-routes=false")
	}

	// 添加有狀態過濾設置
	if *t.cfg.StatefulFiltering {
		args = append(args, "--stateful-filtering=true")
	} else {
		args = append(args, "--stateful-filtering=false")
	}

	// 添加標籤
	if len(t.cfg.Tags) > 0 {
		args = append(args, "--advertise-tags="+strings.Join(t.cfg.Tags, ","))
	}

	// 添加 Funnel 設置
	if *t.cfg.Funnel {
		args = append(args, "--hostname=homeassistant")
		args = append(args, fmt.Sprintf("--funnel-port=%s", t.cfg.ProxyAndFunnelPort))
	}

	// 添加代理設置
	if *t.cfg.Proxy {
		args = append(args, fmt.Sprintf("--proxy-port=%s", t.cfg.ProxyAndFunnelPort))
	}

	// 執行 tailscale up 命令
	log.Printf("配置 tailscale: %s %s", tailscalePath, strings.Join(args, " "))
	cmd := exec.Command(tailscalePath, args...)

	// 獲取認證 URL
	var outBuf, errBuf bytes.Buffer
	cmd.Stdout = io.MultiWriter(os.Stdout, &outBuf)
	cmd.Stderr = io.MultiWriter(os.Stderr, &errBuf)

	if err := cmd.Run(); err != nil {
		log.Printf("執行 tailscale up 失敗，但這可能是正常的，因為需要認證")
	}

	// 從輸出中提取認證 URL
	output := outBuf.String() + errBuf.String()
	authURL := extractAuthURL(output)
	if authURL != "" {
		t.mu.Lock()
		t.authURL = authURL
		t.mu.Unlock()
		log.Printf("提取到認證 URL: %s", authURL)
	} else {
		log.Printf("未能從輸出中提取認證 URL，請檢查日誌")
		log.Printf("輸出: %s", output)
	}

	return nil
}

// 監控 Tailscale 狀態
func (t *Tailscale) monitorStatus() {
	// 如果是模擬模式，不實際監控狀態
	if simulationMode {
		return
	}

	// 使用 tmpfs 目錄
	tmpDir := "/tmp/tailscale"
	socketPath := filepath.Join(tmpDir, "tailscaled.sock")

	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-t.ctx.Done():
			return
		case <-ticker.C:
			t.updateStatus(socketPath)
		}
	}
}

// 更新 Tailscale 狀態
func (t *Tailscale) updateStatus(socketPath string) {
	// 如果是模擬模式，不實際更新狀態
	if simulationMode {
		return
	}

	// 檢查 tailscale 是否存在
	tailscalePath, err := exec.LookPath("tailscale")
	if err != nil {
		log.Printf("找不到 tailscale: %v", err)
		return
	}

	// 執行 tailscale status 命令
	cmd := exec.Command(tailscalePath, "--socket="+socketPath, "status", "--json")
	output, err := cmd.Output()
	if err != nil {
		log.Printf("執行 tailscale status 失敗: %v", err)
		return
	}

	// 解析 JSON 輸出
	var status struct {
		Self struct {
			DNSName      string   `json:"DNSName"`
			Addresses    []string `json:"Addresses"`
			TailscaleIPs []string `json:"TailscaleIPs"`
		} `json:"Self"`
		BackendState string `json:"BackendState"`
	}

	if err := json.Unmarshal(output, &status); err != nil {
		log.Printf("解析 tailscale status 輸出失敗: %v", err)
		return
	}

	// 更新狀態
	t.mu.Lock()
	defer t.mu.Unlock()

	t.status = status.BackendState
	if len(status.Self.TailscaleIPs) > 0 {
		t.ipAddress = status.Self.TailscaleIPs[0]
	} else if len(status.Self.Addresses) > 0 {
		t.ipAddress = status.Self.Addresses[0]
	}

	// 如果已經連接，清除認證 URL
	if t.status == "Running" {
		t.authURL = ""
	}
}

func extractAuthURL(output string) string {
	// 嘗試匹配不同格式的認證 URL
	patterns := []string{
		"To authenticate, visit:",
		"To authorize your machine, visit:",
		"To log in, visit:",
		"Please visit:",
		"Visit:",
	}

	lines := strings.Split(output, "\n")
	for _, line := range lines {
		for _, pattern := range patterns {
			if strings.Contains(line, pattern) {
				parts := strings.SplitN(line, pattern, 2)
				if len(parts) > 1 {
					url := strings.TrimSpace(parts[1])
					// 確保 URL 以 http 開頭
					if strings.HasPrefix(url, "http") {
						return url
					}
				}
			}
		}
		// 直接尋找 https://login.tailscale.com/
		if strings.Contains(line, "https://login.tailscale.com/") {
			words := strings.Fields(line)
			for _, word := range words {
				if strings.HasPrefix(word, "https://login.tailscale.com/") {
					return word
				}
			}
		}
	}
	return ""
}

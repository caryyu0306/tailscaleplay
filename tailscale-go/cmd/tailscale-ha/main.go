package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"

	"github.com/yourusername/tailscale/internal/config"
	"github.com/yourusername/tailscale/internal/tailscale"
)

var (
	configFile = flag.String("config", "/data/options.json", "配置文件路徑")
	testMode   = flag.Bool("test", false, "測試模式")
	simMode    = flag.Bool("sim", false, "模擬模式")
	dockerMode = flag.Bool("docker", false, "Docker 模式")
	version    = "dev"
)

func main() {
	flag.Parse()

	// 設置日誌格式
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	log.Printf("Tailscale 附加元件 (版本: %s) 啟動中...", version)

	// 檢查是否為 Docker 模式
	if *dockerMode {
		log.Println("運行在 Docker 模式下")
		// 確保目錄存在
		os.MkdirAll("/data", 0755)
		os.MkdirAll("/share/taildrop", 0755)
	}

	// 檢查是否為測試模式
	if *testMode {
		log.Println("運行在測試模式下")
		// 在測試模式下使用相對路徑
		if filepath.IsAbs(*configFile) {
			*configFile = filepath.Base(*configFile)
		}

		// 設置測試目錄
		config.SetTestMode("./test-data", "./test-share/taildrop")
	}

	// 檢查是否為模擬模式
	if *simMode {
		log.Println("運行在模擬模式下")
		tailscale.SetSimulationMode(true)
	}

	// 加載配置
	cfg, err := config.LoadConfig(*configFile)
	if err != nil {
		log.Fatalf("無法加載配置: %v", err)
	}

	// 設置日誌級別
	config.SetLogLevel(cfg.LogLevel)

	// 初始化 Tailscale 客戶端
	ts, err := tailscale.New(cfg)
	if err != nil {
		log.Fatalf("初始化 Tailscale 失敗: %v", err)
	}

	// 啟動 Tailscale
	if err := ts.Start(); err != nil {
		log.Fatalf("啟動 Tailscale 失敗: %v", err)
	}
	defer ts.Stop()

	// 等待信號
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	sig := <-sigCh
	log.Printf("收到信號 %v，正在關閉...", sig)

	fmt.Println("Tailscale 附加元件已關閉")
}

package config

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"os"
)

// 測試模式設置
var (
	isTestMode      bool
	testStateDir    string
	testTaildropDir string
)

// Config 代表附加元件的配置
type Config struct {
	// 基本配置
	AcceptDNS           *bool    `json:"accept_dns"`
	AcceptRoutes        *bool    `json:"accept_routes"`
	AdvertiseExitNode   *bool    `json:"advertise_exit_node"`
	AdvertiseConnector  *bool    `json:"advertise_connector"`
	AdvertiseRoutes     []string `json:"advertise_routes"`
	Funnel              *bool    `json:"funnel"`
	LogLevel            string   `json:"log_level"`
	LoginServer         string   `json:"login_server"`
	Proxy               *bool    `json:"proxy"`
	ProxyAndFunnelPort  string   `json:"proxy_and_funnel_port"`
	SNATSubnetRoutes    *bool    `json:"snat_subnet_routes"`
	StatefulFiltering   *bool    `json:"stateful_filtering"`
	Tags                []string `json:"tags"`
	Taildrop            *bool    `json:"taildrop"`
	UserspaceNetworking *bool    `json:"userspace_networking"`

	// 內部配置
	StateDir    string `json:"-"`
	TaildropDir string `json:"-"`
}

// SetTestMode 設置測試模式
func SetTestMode(stateDir, taildropDir string) {
	isTestMode = true
	testStateDir = stateDir
	testTaildropDir = taildropDir
	log.Printf("測試模式已啟用，使用目錄: %s, %s", stateDir, taildropDir)
}

// LoadConfig 從指定的文件路徑加載配置
func LoadConfig(path string) (*Config, error) {
	// 設置默認配置
	cfg := &Config{
		StateDir:    "/data/tailscale",
		TaildropDir: "/share/taildrop",
		LogLevel:    "info",
		LoginServer: "https://controlplane.tailscale.com",
	}

	// 如果是測試模式，使用測試目錄
	if isTestMode {
		cfg.StateDir = testStateDir
		cfg.TaildropDir = testTaildropDir
	}

	// 如果配置文件存在，則從文件加載
	if _, err := os.Stat(path); err == nil {
		log.Printf("從 %s 加載配置", path)
		data, err := ioutil.ReadFile(path)
		if err != nil {
			return nil, err
		}

		if err := json.Unmarshal(data, cfg); err != nil {
			return nil, err
		}
	} else {
		log.Printf("配置文件 %s 不存在，使用默認配置", path)
	}

	// 確保目錄存在
	if err := os.MkdirAll(cfg.StateDir, 0755); err != nil {
		return nil, err
	}
	if err := os.MkdirAll(cfg.TaildropDir, 0755); err != nil {
		return nil, err
	}

	// 設置默認值
	if cfg.AcceptDNS == nil {
		trueVal := true
		cfg.AcceptDNS = &trueVal
	}
	if cfg.AcceptRoutes == nil {
		trueVal := true
		cfg.AcceptRoutes = &trueVal
	}
	if cfg.AdvertiseExitNode == nil {
		trueVal := true
		cfg.AdvertiseExitNode = &trueVal
	}
	if cfg.AdvertiseConnector == nil {
		trueVal := true
		cfg.AdvertiseConnector = &trueVal
	}
	if cfg.Funnel == nil {
		falseVal := false
		cfg.Funnel = &falseVal
	}
	if cfg.Proxy == nil {
		falseVal := false
		cfg.Proxy = &falseVal
	}
	if cfg.ProxyAndFunnelPort == "" {
		cfg.ProxyAndFunnelPort = "443"
	}
	if cfg.SNATSubnetRoutes == nil {
		trueVal := true
		cfg.SNATSubnetRoutes = &trueVal
	}
	if cfg.StatefulFiltering == nil {
		falseVal := false
		cfg.StatefulFiltering = &falseVal
	}
	if cfg.Taildrop == nil {
		trueVal := true
		cfg.Taildrop = &trueVal
	}
	if cfg.UserspaceNetworking == nil {
		trueVal := true
		cfg.UserspaceNetworking = &trueVal
	}

	// 輸出配置信息
	log.Printf("配置加載完成:")
	log.Printf("  StateDir: %s", cfg.StateDir)
	log.Printf("  TaildropDir: %s", cfg.TaildropDir)
	log.Printf("  LogLevel: %s", cfg.LogLevel)
	log.Printf("  LoginServer: %s", cfg.LoginServer)

	return cfg, nil
}

// SetLogLevel 根據配置設置日誌級別
func SetLogLevel(level string) {
	switch level {
	case "trace", "debug":
		log.SetFlags(log.LstdFlags | log.Lshortfile | log.Lmicroseconds)
		log.Println("日誌級別設置為:", level)
	case "info", "notice", "warning", "error", "fatal":
		log.SetFlags(log.LstdFlags)
		log.Println("日誌級別設置為:", level)
	default:
		log.SetFlags(log.LstdFlags)
		log.Println("未知的日誌級別:", level, "使用默認級別: info")
	}
}

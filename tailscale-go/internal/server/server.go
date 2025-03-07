package server

import (
	"context"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"time"

	"github.com/yourusername/tailscale-ha/internal/config"
	"github.com/yourusername/tailscale-ha/internal/tailscale"
)

// 定義 HTML 模板
const indexTemplate = `<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tailscale Home Assistant 附加元件</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            color: #3498db;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .status-box {
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 20px;
            margin: 20px 0;
        }
        .status-item {
            margin-bottom: 10px;
        }
        .status-label {
            font-weight: bold;
            display: inline-block;
            width: 120px;
        }
        .auth-box {
            background-color: #e8f4fc;
            border: 1px solid #3498db;
            border-radius: 5px;
            padding: 20px;
            margin: 20px 0;
        }
        .auth-link {
            display: inline-block;
            background-color: #3498db;
            color: white;
            padding: 10px 15px;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 10px;
        }
        .auth-link:hover {
            background-color: #2980b9;
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <h1>Tailscale Home Assistant 附加元件</h1>
    
    <div class="status-box">
        <h2>Tailscale 狀態</h2>
        <div class="status-item">
            <span class="status-label">狀態:</span>
            <span id="status">{{.Status}}</span>
        </div>
        <div class="status-item">
            <span class="status-label">IP 地址:</span>
            <span id="ip-address">{{.IPAddress}}</span>
        </div>
    </div>
    
    <div class="auth-box {{if not .AuthURL}}hidden{{end}}">
        <h2>需要認證</h2>
        <p>請點擊下面的連結完成 Tailscale 認證:</p>
        <a href="{{.AuthURL}}" target="_blank" class="auth-link">前往 Tailscale 認證</a>
    </div>

    <div class="info-box">
        <h2>使用說明</h2>
        <p>Tailscale 是一種零配置 VPN，可讓您在不同設備和網絡之間建立安全連接。使用 Tailscale，您可以從任何地方安全地訪問您的 Home Assistant。</p>
        <p>主要功能:</p>
        <ul>
            <li>從任何地方安全地訪問您的 Home Assistant</li>
            <li>無需端口轉發或 DynamicDNS</li>
            <li>連接到您家中的所有智能家居設備</li>
            <li>在公共 Wi-Fi 上安全地瀏覽互聯網</li>
        </ul>
        <p>更多信息請參閱 <a href="https://github.com/hassio-addons/addon-tailscale" target="_blank">GitHub 存儲庫</a>。</p>
    </div>

    <script>
        // 定期更新狀態
        function updateStatus() {
            fetch('/status')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('status').textContent = data.status;
                    document.getElementById('ip-address').textContent = data.ip_address;
                })
                .catch(error => console.error('更新狀態時出錯:', error));
        }

        // 每 10 秒更新一次狀態
        setInterval(updateStatus, 10000);
    </script>
</body>
</html>`

// Server 代表 Web 服務器
type Server struct {
	cfg       *config.Config
	ts        *tailscale.Tailscale
	server    *http.Server
	templates *template.Template
}

// New 創建一個新的 Web 服務器
func New(cfg *config.Config, ts *tailscale.Tailscale) *Server {
	templates := template.Must(template.New("index").Parse(indexTemplate))
	return &Server{
		cfg:       cfg,
		ts:        ts,
		templates: templates,
	}
}

// Start 啟動 Web 服務器
func (s *Server) Start() error {
	mux := http.NewServeMux()
	mux.HandleFunc("/", s.handleIndex)
	mux.HandleFunc("/status", s.handleStatus)

	s.server = &http.Server{
		Addr:    ":8099",
		Handler: mux,
	}

	log.Printf("啟動 Web 服務器在 %s", s.server.Addr)

	// 在新的 goroutine 中啟動服務器
	go func() {
		if err := s.server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Printf("Web 服務器錯誤: %v", err)
		}
	}()

	return nil
}

// Stop 停止 Web 服務器
func (s *Server) Stop() error {
	if s.server == nil {
		return nil
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	log.Println("正在停止 Web 服務器...")
	return s.server.Shutdown(ctx)
}

// handleIndex 處理首頁請求
func (s *Server) handleIndex(w http.ResponseWriter, r *http.Request) {
	data := map[string]interface{}{
		"AuthURL":   s.ts.GetAuthURL(),
		"Status":    s.ts.GetStatus(),
		"IPAddress": s.ts.GetIPAddress(),
	}

	if err := s.templates.ExecuteTemplate(w, "index", data); err != nil {
		http.Error(w, fmt.Sprintf("模板渲染錯誤: %v", err), http.StatusInternalServerError)
	}
}

// handleStatus 處理狀態請求
func (s *Server) handleStatus(w http.ResponseWriter, r *http.Request) {
	data := map[string]interface{}{
		"Status":    s.ts.GetStatus(),
		"IPAddress": s.ts.GetIPAddress(),
		"Time":      time.Now().Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{"status":"%s","ip_address":"%s","time":"%s"}`,
		data["Status"], data["IPAddress"], data["Time"])
}

# web-app 檢查 hook。由 doctor.sh source。
check_skill e2e-from-spec
mcp_registered playwright && ok "Playwright MCP 已註冊" || bad "Playwright MCP 未註冊（核心安裝應已處理，重跑 install.sh）"

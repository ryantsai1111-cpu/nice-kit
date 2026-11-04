# legacy-consulting 檢查 hook。由 doctor.sh source。
check_skill grill-the-client
check_skill inventory-gaps
check_skill characterization-tests
if npx -y rea-agents@latest --version >/dev/null 2>&1; then
  ok "rea-agents 可執行"
  mcp_registered rea && ok "REA 已註冊到至少一個 agent" || warn "REA 尚未註冊：npx rea-agents setup"
else
  warn "rea-agents 無法執行：npx rea-agents setup"
fi

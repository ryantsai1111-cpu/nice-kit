# legacy-consulting 安裝 hook。由 install.sh source，可用 lib.sh 的函式與 $AGENTS / $SKIP_REA。
if [ "${SKIP_REA:-0}" -eq 0 ]; then
  say "[legacy-consulting] 註冊 REA（互動式，它自己會列出支援的 agent 讓你勾）"
  npx -y rea-agents@latest setup
else
  say "[legacy-consulting] 略過 REA（--skip-rea）"
fi
echo "資料庫 MCP 依客戶環境不同，見 packs/legacy-consulting/docs/db-mcp.md"

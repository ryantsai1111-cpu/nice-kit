param([switch]$SkipRea)
if (-not $SkipRea) {
  Write-Host "`n==> [legacy-consulting] 註冊 REA（互動式）" -ForegroundColor Cyan
  npx -y rea-agents@latest setup
} else {
  Write-Host "`n==> [legacy-consulting] 略過 REA" -ForegroundColor Cyan
}
Write-Host "資料庫 MCP 依客戶環境不同，見 packs/legacy-consulting/docs/db-mcp.md"

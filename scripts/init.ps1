# 開新案（Windows PowerShell）
# 用法：.\scripts\init.ps1 <案名> [-Agents claude-code,codex,...]
param(
  [Parameter(Mandatory=$true, Position=0)][string]$Name,
  [string[]]$Agents = @()
)
$ErrorActionPreference = "Stop"
$KitDir = Split-Path -Parent $PSScriptRoot
function Have($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }
if (-not (Have specify)) { Write-Error "缺少 specify，請先跑 scripts\install.ps1" }

if ($Agents.Count -eq 0) {
  $map = @{ claude="claude-code"; codex="codex"; cursor="cursor"; gemini="gemini-cli"; copilot="github-copilot"; opencode="opencode" }
  $Agents = $map.Keys | Where-Object { Have $_ } | ForEach-Object { $map[$_] }
  if ($Agents.Count -eq 0) { $Agents = @("claude-code") }
}
$toSpecKit = @{
  "claude-code"="claude"; "codex"="codex"; "cursor"="cursor-agent"; "gemini-cli"="gemini";
  "github-copilot"="copilot"; "opencode"="opencode"; "windsurf"="windsurf"; "roo"="roo";
  "kilo"="kilocode"; "qwen-code"="qwen"; "amp"="amp"; "codebuddy"="codebuddy"
}
$first = $toSpecKit[$Agents[0]]
if (-not $first) { Write-Error "spec-kit 不支援 $($Agents[0])，請用 -Agents 指定一個支援的主要 agent" }

Write-Host "==> specify init $Name --integration $first"
specify init $Name --integration $first --ignore-agent-tools --script ps
Set-Location $Name
foreach ($a in $Agents[1..($Agents.Count-1)]) {
  $sk = $toSpecKit[$a]
  if (-not $sk) { Write-Host "   略過 $a（spec-kit 不支援）"; continue }
  Write-Host "==> 補 $sk 的 spec-kit 指令"
  try { specify init --here --integration $sk --ignore-agent-tools --script ps --force | Out-Null } catch {}
}

Write-Host "==> 放入 nice-kit 範本"
Copy-Item "$KitDir\templates\AGENTS.md", "$KitDir\templates\CLAUDE.md", "$KitDir\templates\GEMINI.md", "$KitDir\templates\PROGRESS.md" .
New-Item -ItemType Directory -Force -Path ".cursor\rules", ".grill", "inventory" | Out-Null
Copy-Item "$KitDir\templates\.cursor\rules\nice-kit.mdc" ".cursor\rules\"
if (-not (Test-Path .git)) { git init -q }
Add-Content .gitignore ".grill/`ninventory/`n.env"

Write-Host @"

專案 $Name 已建立。agent：$($Agents -join ',')
  1. 填 AGENTS.md 裡的 <>
  2. 用你的 agent 開啟這個目錄
  3. 載入 grill-the-client skill 開始第一輪訪談
"@

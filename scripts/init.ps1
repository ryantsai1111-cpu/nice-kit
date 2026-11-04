# 開新案（Windows PowerShell）
# 用法：.\scripts\init.ps1 <案名> [-Pack legacy-consulting] [-Agents claude-code,codex,...]
param(
  [Parameter(Mandatory=$true, Position=0)][string]$Name,
  [string]$Pack = "",
  [string[]]$Agents = @()
)
$ErrorActionPreference = "Stop"
$KitDir   = Split-Path -Parent $PSScriptRoot
$PacksDir = Join-Path $KitDir "packs"
function Have($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }
if (-not (Have specify)) { Write-Error "缺少 specify，請先跑 scripts\install.ps1" }

$packInfo = $null
if ($Pack) {
  $conf = Join-Path $PacksDir "$Pack\pack.conf"
  if (-not (Test-Path $conf)) { Write-Error "找不到 pack：$Pack" }
  $packInfo = @{ DIR=(Join-Path $PacksDir $Pack); INIT_DIRS=""; GITIGNORE="" }
  Get-Content $conf | Where-Object { $_ -match '^PACK_(\w+)=(.*)$' } | ForEach-Object { $packInfo[$Matches[1]] = $Matches[2].Trim('"') }
}

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

Write-Host "==> 放入 nice-kit 核心範本"
Copy-Item "$KitDir\templates\AGENTS.md", "$KitDir\templates\CLAUDE.md", "$KitDir\templates\GEMINI.md", "$KitDir\templates\PROGRESS.md" .
New-Item -ItemType Directory -Force -Path ".cursor\rules" | Out-Null
Copy-Item "$KitDir\templates\.cursor\rules\nice-kit.mdc" ".cursor\rules\"
if (-not (Test-Path .git)) { git init -q }
Add-Content .gitignore ".env`n.env.*"

if ($packInfo) {
  Write-Host "==> 附加 pack：$Pack"
  $sect = Join-Path $packInfo.DIR "templates\AGENTS.pack.md"
  if (Test-Path $sect) { Add-Content AGENTS.md ("`n" + (Get-Content $sect -Raw)) }
  $tpl = Join-Path $packInfo.DIR "templates"
  if (Test-Path $tpl) {
    Get-ChildItem $tpl -Recurse -File | Where-Object { $_.Name -ne "AGENTS.pack.md" } | ForEach-Object {
      $rel = $_.FullName.Substring($tpl.Length + 1)
      $dst = Split-Path $rel -Parent
      if ($dst) { New-Item -ItemType Directory -Force -Path $dst | Out-Null }
      Copy-Item $_.FullName $rel
    }
  }
  if ($packInfo.INIT_DIRS) { $packInfo.INIT_DIRS -split "," | ForEach-Object { New-Item -ItemType Directory -Force -Path $_.Trim() | Out-Null } }
  if ($packInfo.GITIGNORE) { Add-Content .gitignore (($packInfo.GITIGNORE -split ",") -join "`n") }
  Set-Content .nice-kit "pack: $Pack"
  $hook = Join-Path $packInfo.DIR "hooks\init.ps1"
  if (Test-Path $hook) { & $hook }
} else {
  Set-Content .nice-kit "pack: none"
}

Write-Host @"

專案 $Name 已建立。agent：$($Agents -join ',')$(if ($Pack) { "，pack：$Pack" })
  1. 填 AGENTS.md 裡的 <>
  2. 用你的 agent 開啟這個目錄
  3. 從 spec-kit 的 constitution 開始$(if ($Pack) { "；pack 的流程見 $KitDir\packs\$Pack\README.md" })
"@

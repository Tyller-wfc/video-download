param(
  [Parameter(Mandatory=$true)][string]$InJson,
  [Parameter(Mandatory=$true)][string]$OutTxt
)

$ErrorActionPreference = 'Stop'

if (!(Test-Path -LiteralPath $InJson)) {
  Write-Error "Input JSON not found: $InJson"
  exit 2
}

# 读取与解析
$raw = Get-Content -LiteralPath $InJson -Raw -Encoding UTF8
try {
  $json = $raw | ConvertFrom-Json
} catch {
  Write-Error "JSON 解析失败：$($_.Exception.Message)"
  exit 3
}

if (-not $json) {
  Write-Error "JSON 为空"
  exit 4
}

# 过滤 https://www.wyav.tv/watch? 开头的链接
$watch = $json | Where-Object { $_ -like 'https://www.wyav.tv/watch?*' }

# 输出 UTF-8（无 BOM）
$watch | Out-File -LiteralPath $OutTxt -Encoding UTF8

Write-Host ("筛选到 {0} 条 watch 链接" -f $watch.Count)
exit 0

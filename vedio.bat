@echo off
setlocal
chcp 65001 >nul

REM ===== 配置 =====
set "API_URL=http://localhost:8080/crawler?url=https://wyav.tv"
set "OUT_JSON=crawler.json"
set "OUT_TXT=watch_urls.txt"
set "TIMEOUT_SEC=30"
REM ===============

echo [*] 拉取接口数据到 %OUT_JSON% ...

where curl >nul 2>nul
if %errorlevel%==0 (
  curl -s --max-time %TIMEOUT_SEC% "%API_URL%" > "%OUT_JSON%"
  set "RCUR=%ERRORLEVEL%"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass ^
    -Command "try{(Invoke-WebRequest -Uri '%API_URL%' -TimeoutSec %TIMEOUT_SEC% -UseBasicParsing).Content | Out-File -LiteralPath '%OUT_JSON%' -Encoding UTF8; exit 0}catch{ Write-Error $_; exit 1 }"
  set "RCUR=%ERRORLEVEL%"
)

if not "%RCUR%"=="0" (
  echo [x] 下载失败，退出码=%RCUR%
  exit /b 1
)

if not exist "%OUT_JSON%" (
  echo [x] 未生成 %OUT_JSON%
  exit /b 2
)

for %%A in ("%OUT_JSON%") do if %%~zA lss 2 (
  echo [x] %OUT_JSON% 内容为空
  exit /b 3
)

echo [*] 解析并筛选 watch 链接到 %OUT_TXT% ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0parse_watch.ps1" "%OUT_JSON%" "%OUT_TXT%"
set "PRC=%ERRORLEVEL%"
if not "%PRC%"=="0" (
  echo [x] 解析失败（err=%PRC%），请检查 %OUT_JSON%
  exit /b 4
)

for /f "usebackq delims=" %%C in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-Content -LiteralPath '%OUT_TXT%').Count"`) do set "COUNT=%%C"
if "%COUNT%"=="" set "COUNT=0"

echo [√] 成功：共 %COUNT% 条链接写入 %OUT_TXT%
endlocal
exit /b 0

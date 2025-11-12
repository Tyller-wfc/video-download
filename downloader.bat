@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ========= 脚本目录 =========
set "BASEDIR=%~dp0"
pushd "%BASEDIR%"

rem ========= 依赖/文件检查 =========
where yt-dlp >nul 2>nul || (echo [ERROR] 未找到 yt-dlp，請先: pip install yt-dlp & goto :END)
if not exist "capture_m3u8.py" (echo [ERROR] 缺少 capture_m3u8.py & goto :END)
if not exist "watch_urls.txt" (echo [ERROR] 缺少 watch_urls.txt & goto :END)

echo [INFO] 開始處理 watch_urls.txt
echo.

rem ========= 循环读取 URL (纯 cmd) =========
for /f "usebackq delims=" %%L in ("watch_urls.txt") do (
    set "URL=%%L"

    rem -- 去掉前导空格（尾部空格不影响）
    for /f "tokens=* delims= " %%A in ("!URL!") do set "URL=%%A"

    rem -- 从第一个 http 开始（清除 BOM/乱码），并修复 ttps:// -> https://
    set "URL=!URL:*http=http!"
    if /I "!URL:~0,7!"=="ttps://" set "URL=h!URL!"

    rem -- 跳过空行/注释行
    if "!URL!"=="" (
        rem 空
    ) else if "!URL:~0,1!"=="#" (
        echo [INFO] Skip comment: !URL!
    ) else (
        echo [INFO] Processing: !URL!

        rem -- 调用 Python 抓取第一个 chunklist.m3u8（只取第一行）
        set "M3U8="
        for /f "delims=" %%M in ('python "capture_m3u8.py" "!URL!" 2^>nul') do (
            if not defined M3U8 set "M3U8=%%M"
        )

        if not defined M3U8 (
            echo [WARN] 未捕獲到 chunklist.m3u8，跳過
            echo.
        ) else (
            echo [INFO] 捕獲到 m3u8：!M3U8!

            rem -- 生成 16 位随机文件名（稳定）
            call :GenRand
            set "OUT=!RAND!.mp4"

            echo [INFO] 下載文件：!OUT!
            yt-dlp -N 16 -o "!OUT!" "!M3U8!"
            if errorlevel 1 (
                echo [WARN] 下載失敗：!OUT!
            ) else (
                echo [INFO] 下載完成：!OUT!
            )
            echo.
        )
    )
)

goto :END

:GenRand
rem 纯 cmd 的随机 16 位（不会为空/不会重复成 “+.mp4”）
set "RAND=%RANDOM%%RANDOM%%RANDOM%%RANDOM%"
set "RAND=%RAND:~0,16%"
exit /b

:END
popd
endlocal

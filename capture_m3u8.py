#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
只抓取页面所有网络请求中包含 "chunklist.m3u8" 的 URL，并直接打印。
依赖：playwright
安装：
    pip install playwright
    playwright install chromium

运行示例：
    python capture_m3u8.py "https://www.wyav.tv/watch?v=7z0vv9C1gU4"
"""

import sys
import time
from playwright.sync_api import sync_playwright

def main():
    if len(sys.argv) < 2:
        print("用法: python capture_m3u8.py <url>")
        sys.exit(1)

    url = sys.argv[1]

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()

        found = set()

        def on_request(req):
            u = req.url
            if "chunklist.m3u8" in u:
                if u not in found:
                    found.add(u)
                    print(u)

        page.on("request", on_request)

        # 打开页面
        page.goto(url, wait_until="domcontentloaded", timeout=60000)

        # 主动滚动触发懒加载
        try:
            for _ in range(5):
                page.mouse.wheel(0, 2000)
                page.wait_for_timeout(500)
        except:
            pass

        # 再监听 10 秒
        page.wait_for_timeout(10000)

        context.close()
        browser.close()

if __name__ == "__main__":
    main()

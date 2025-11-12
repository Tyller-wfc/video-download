# 视频下载

1.通过vedio.bat批处理脚本实现如下功能
  1.1.通过调用web-crawler项目爬取目标网站的二级链接
  1.2.将爬取到的二级链接通过parse_watch.ps1脚本进行整理，获取自己想要的数据保存到watch_urls.txt
2.通过downloader.bat批处理脚本，实现如下功能
  2.1.逐行获取watch_urls.txt中的视频地址
  2.2.通过capture_m3u8.py实现视频下载
    2.2.1.配置python环境，使用python3.12版本，下载playwright依赖
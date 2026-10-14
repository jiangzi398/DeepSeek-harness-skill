@echo off
chcp 65001 >nul
title api-monitor - 硅基流动用量监控
echo ============================================================
echo   api-monitor  硅基流动(SiliconFlow) API 用量监控
echo   [Windows 一键启动]  关闭本窗口即停止代理
echo ============================================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [错误] 没有找到 Node.js。
  echo [解决] 请先到 https://nodejs.org 下载并安装 Node.js（一路下一步即可），
  echo        安装完成后重新双击本文件。
  echo.
  pause
  exit /b 1
)

node proxy-server.js
set EXIT=%errorlevel%
echo.
echo 代理已退出。下面是常见情况：
if "%EXIT%"=="0" ( echo   正常结束。 )
echo   - 端口被占用：请把第 7 行附近的环境变量改成其它端口再启动，例如：
echo       set DSH_PROXY_PORT=8788
echo   - 其它报错：详看上方信息，或打开 logs\run.log 查看运行日志。
echo.
pause

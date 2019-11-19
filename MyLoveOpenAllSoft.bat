@echo off
:: 获取管理员权限
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit



:: 两个::是注释
start "" "D:\Common\VimD\userPlugins\InitProgram.ahk"
start "" "D:\Common\VimD\vimd.exe"
start "" "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
start "" "C:\Program Files\Listary\Listary.exe"



:: start "" "E:\ZPCode\zp.ymt\ZP.YMT.sln"

:: vid有点问题先关闭再打开
taskkill /f /im vimd.exe
start "" "D:\Common\VimD\vimd.exe"
start "" "D:\software\Navicat Premium 12\navicat.exe" 
:: start "" "C:\Program Files (x86)\Microsoft SQL Server\120\Tools\Binn\ManagementStudio\Ssms.exe"
:: start "" "D:\Common\VimD\userPlugins\CodePrompt\CodePrompt.exe"

:: 打开qq
start "" "D:\MyLove\AHK\OpenMyLoveQQ.ahk"
exit
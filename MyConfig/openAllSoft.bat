@echo off
:: 获取管理员权限
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit



:: 两个::是注释
start "" "D:\MyLove\VimD\userPlugins\InitProgram.ahk"
:: 两个qq号
start "" "C:\Program Files (x86)\Tencent\QQ\Bin\QQ.exe"
start "" "C:\Program Files (x86)\Tencent\QQ\Bin\QQ.exe"
start "" "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"

start "" "D:\MyLove\VimD\vimd.exe"

:: start "" "E:\ZPCode\SERP3.0\SERP3.0.sln"
start "" "E:\ZPCode\SuYa_V2\SuYa_V2.sln"
:: start "" "E:\ZPCode\Mifei_v2\Mifei_v2.sln"

start "" "C:\Program Files\Listary\Listary.exe"
:: vid有点问题先关闭再打开
taskkill /f /im vimd.exe
start "" "D:\MyLove\VimD\vimd.exe"
start "" "C:\Program Files\PremiumSoft\Navicat Premium 12\navicat.exe" 
:: start "" "C:\Program Files (x86)\Microsoft SQL Server\120\Tools\Binn\ManagementStudio\Ssms.exe"
start "" "D:\MyLove\VimD\userPlugins\CodePrompt\CodePrompt.exe"
exit
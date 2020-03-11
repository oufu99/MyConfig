@echo off
:: 获取管理员权限
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

:: 两个::是注释
start "" "D:\MyLoove\AHK\MyLoove.ahk"
:: start "" "D:\MyLoove\AHK\OpenMyLooveQQ.ahk"
start "" "D:\Common\VimD\vimd.exe"
:: vid有点问题先关闭再打开
taskkill /f /im vimd.exe
start "" "D:\Common\VimD\vimd.exe"

start "" "D:\Dossen\代码\Dossen\EC-AutoHotelMapping\EC.AutoHotelMapping.sln"
start "" "D:\Dossen\代码\Dossen\OTA-Interface\Web.Interface.sln"

exit
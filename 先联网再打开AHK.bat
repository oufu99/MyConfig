echo off
:: 获取管理员权限
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit



:: 两个::是注释
start "" "D:\Mirror2\AutoInternet\bin\Debug\AutoInternet.exe"
exit
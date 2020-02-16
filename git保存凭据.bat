@echo off
:: 获取管理员权限
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

set "dicPath=D:"
for %%i in (Common Mirror Mirror2 MyConfig MyLove MyLoove Tools) do  (%dicPath% 
cd %dicPath%\%%i\ 
echo beginAction:%dicPath%\%%i\ 
git config  credential.helper store 
git pull)
exit

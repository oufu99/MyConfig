@echo off
:: ��ȡ����ԱȨ��
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit



:: ����::��ע��
start "" "D:\Mirror2\AutoInternet\bin\Debug\AutoInternet.exe"
exit
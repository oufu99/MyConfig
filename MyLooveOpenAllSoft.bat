@echo off
:: ��ȡ����ԱȨ��
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

:: ����::��ע��
start "" "D:\MyLoove\AHK\StartAllMyLooveAhk.ahk"
:: start "" "D:\MyLoove\AHK\OpenMyLooveQQ.ahk"
start "" "D:\Common\VimD\vimd.ahk"
:: vid�е������ȹر��ٴ�
taskkill /f /im vimd.exe
start "" "D:\Common\VimD\vimd.ahk"
exit
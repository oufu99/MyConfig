@echo off
:: ��ȡ����ԱȨ��
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

:: ����::��ע��
start "" "D:\MyLoove\AHK\MyLoove.ahk"
:: start "" "D:\MyLoove\AHK\OpenMyLooveQQ.ahk"
start "" "D:\Common\VimD\vimd.exe"
:: vid�е������ȹر��ٴ�
taskkill /f /im vimd.exe
start "" "D:\Common\VimD\vimd.exe"

start "" "D:\Dossen\����\Dossen\EC-AutoHotelMapping\EC.AutoHotelMapping.sln"
start "" "D:\Dossen\����\Dossen\OTA-Interface\Web.Interface.sln"

exit
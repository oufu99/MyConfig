@echo off
:: ��ȡ����ԱȨ��
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit



:: ����::��ע��
start "" "D:\MyLove\AHK\StartAllMyLoveAhk.ahk"
start "" "D:\Common\VimD\vimd.exe"
start "" "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
start "" "C:\Program Files\Listary\Listary.exe"
:: vid�е������ȹر��ٴ�
taskkill /f /im vimd.exe
start "" "D:\Common\VimD\vimd.exe"
start "" "D:\software\Navicat Premium 12\navicat.exe" 
start "" "D:\software\WizNote\Wiz.exe"
start "" "E:\Dossen\EC-AutoHotelMapping\EC.AutoHotelMapping.sln"
start "" "E:\Dossen\OTA-Interface\Web.Interface.sln"

:: ��qq
start "" "D:\MyLove\AHK\OpenMyLoveQQ.ahk" 
exit
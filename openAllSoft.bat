@echo off
:: ��ȡ����ԱȨ��
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit



:: ����::��ע��
start "" "D:\Common\VimD\userPlugins\InitProgram.ahk"
start "" "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
start "" "C:\Program Files\Listary\Listary.exe"


start "" "D:\Common\VimD\vimd.exe"

:: start "" "E:\ZPCode\SERP3.0\SERP3.0.sln"
:: start "" "E:\ZPCode\SuYa_V2\SuYa_V2.sln"
:: start "" "E:\ZPCode\Mifei_v2\Mifei_v2.sln"
start "" "E:\ZPCode\zp.ymt\ZP.YMT.sln"


start "" "C:\Program Files\Listary\Listary.exe"
:: vid�е������ȹر��ٴ�
taskkill /f /im vimd.exe
start "" "D:\Common\VimD\vimd.exe"
start "" "C:\Program Files\PremiumSoft\Navicat Premium 12\navicat.exe" 
:: start "" "C:\Program Files (x86)\Microsoft SQL Server\120\Tools\Binn\ManagementStudio\Ssms.exe"
:: start "" "D:\Common\VimD\userPlugins\CodePrompt\CodePrompt.exe"



:: ��qq
start "" "D:\Common\VimD\userPlugins\OpenQQ.ahk"
exit
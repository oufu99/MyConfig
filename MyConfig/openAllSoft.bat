@echo off
:: ��ȡ����ԱȨ��
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit



:: ����::��ע��
start "" "D:\MyLove\VimD\userPlugins\InitProgram.ahk"
start "" "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
start "" "C:\Program Files\Listary\Listary.exe"


start "" "D:\MyLove\VimD\vimd.exe"


start "" "C:\Program Files\Listary\Listary.exe"
:: vid�е������ȹر��ٴ�
taskkill /f /im vimd.exe
start "" "D:\MyLove\VimD\vimd.exe"


::  3.0��Ŀ
:: start "" "E:\ZPCode\SERP3.0\SERP3.0.sln"
:: start "" "C:\Program Files (x86)\Microsoft SQL Server\120\Tools\Binn\ManagementStudio\Ssms.exe"


::  4.0�
start "" "E:\ZPCode\zp.ymt\ZP.YMT.sln"
start "" "C:\Program Files\Navicat Premium 12 notsetup\navicat.exe" 


:: ��qq
start "" "D:\MyLove\VimD\userPlugins\OpenQQ.ahk"
exit
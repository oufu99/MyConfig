:: ��Ҫ�Ѷ�Ӧ��Ŀ�������¼�ɾ��  appSetting.json�ĳ��Զ����Ƶ�Ŀ¼
@echo off

 

set "name=E:\ZPCode\"

:: start /min cmd /k "echo %name%zp.ymt\ZP.YMT.Admin&&cd/d %name%zp.ymt\ZP.YMT.Admin&&dotnet run"
:: start /min cmd /k "echo %name%zp.ymt\ZP.YMT.Mobile&&cd/d %name%\zp.ymt\ZP.YMT.Mobile&&dotnet run"

start /min cmd /k "echo %name%zp.ymt\ZP.YMT.Api&&cd/d %name%zp.ymt\ZP.YMT.Api&&dotnet run"
:: start /min cmd /k "echo %name%zp.ymt\ZP.YMT.GoodsApi&&cd/d %name%\zp.ymt\ZP.YMT.GoodsApi&&dotnet run"
start /min cmd /k "echo %name%zp.ymt\ZP.YMT.CustomerApi&&cd/d %name%\zp.ymt\ZP.YMT.CustomerApi&&dotnet run"
:: start /min cmd /k "echo %name%zp.ymt\ZP.YMT.OrderApi&&cd/d %name%\zp.ymt\ZP.YMT.OrderApi&&dotnet run"
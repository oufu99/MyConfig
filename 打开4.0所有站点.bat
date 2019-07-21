:: 需要把对应项目的生成事件删掉  appSetting.json改成自动复制到目录
@echo off

 

set "name=E:\ZPCode\"

:: start /min cmd /k "echo %name%zp.ymt\ZP.YMT.Admin&&cd/d %name%zp.ymt\ZP.YMT.Admin&&dotnet run"
:: start /min cmd /k "echo %name%zp.ymt\ZP.YMT.Mobile&&cd/d %name%\zp.ymt\ZP.YMT.Mobile&&dotnet run"

start /min cmd /k "echo %name%zp.ymt\ZP.YMT.Api&&cd/d %name%zp.ymt\ZP.YMT.Api&&dotnet run"
:: start /min cmd /k "echo %name%zp.ymt\ZP.YMT.GoodsApi&&cd/d %name%\zp.ymt\ZP.YMT.GoodsApi&&dotnet run"
start /min cmd /k "echo %name%zp.ymt\ZP.YMT.CustomerApi&&cd/d %name%\zp.ymt\ZP.YMT.CustomerApi&&dotnet run"
:: start /min cmd /k "echo %name%zp.ymt\ZP.YMT.OrderApi&&cd/d %name%\zp.ymt\ZP.YMT.OrderApi&&dotnet run"
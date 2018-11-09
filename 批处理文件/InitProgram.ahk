#singleinstance force

; 注释  !Alt ^Ctrl +Shift  #Win键

^Numpad0::
   Run, D:\Tools\OpenMyTools\bin\Debug\OpenMyTools.exe
Return

^Numpad1::
   Run, D:\Tools\ScreenCapture\bin\Debug\ScreenCapture.exe
Return

; RButton & c::MsgBox 您按着鼠标中键同时向下滚动了滚轮。

; 模拟vim操作开始
::dd::
  Send, {End}{Shift Down}{Home}{Home}{Shift Up}{Delete}{Delete}
Return
; 模拟vim操作结束


; 密码输入相关

:*:!a::
   Send,{Raw}PT_DSe/XycOhQW_Q8Cu5tIZg_sg
Return

#IfWinActive 连接到服务器
:*:!s::
   Send,{Raw}WA@@@Wei315#@#WinGG
Return
#IfWinActive

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

^x::
{

    MsgBox, % FileExist("C:\Users\dh\.R")
    MsgBox, % FileExist("C:\Users\dh\Documents\.Rhistory")
    Return
}


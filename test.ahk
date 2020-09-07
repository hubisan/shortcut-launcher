#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

^x::
{
    ; Get profile configuration.
    Loop, Files, %A_ScriptDir%\*.lnk
    {
        FileName := A_LoopFileFullPath 
        FileGetShortcut, %FileName%, ProfilePath
        break
    }
}



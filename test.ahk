#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

^x::
{
    test := "C:\Users\dh\Downloads\test.xls"
    SplitPath, test,, OutDir, OutExtension
    if (OutExtension)
    {
        MsgBox, % OutExtension
    }
    Else
    {
        MsgBox, % OutDir
    }
    Return
}
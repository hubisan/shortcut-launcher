#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


test()
{
    MsgBox, % "test"
    return 1
}

#h::
{
    test()
    return
}
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


test()
{
    MsgBox, % "Gedäé"
    return 1
}

#h::
{
    test()
    return
}
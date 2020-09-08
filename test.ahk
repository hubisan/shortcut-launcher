#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

myGetWindowIDs()
{
    winIDs := []
    WinGet, winID, list
    Loop %winID%
    {
        id := winID%A_Index%
        winIDs.Push(id)
    }
    return winIDs
}

myGetNewWindowID(oldWinIDs, currentWinIDs)
{
    newID := 0
    For i, winID1 in currentWinIDs
    {
        For j, winID2 in oldWinIDs
        {
            If (winID1 = winID2)
            {
                newID := 0
                Break
            }
            Else
            {
                newID := 1
            }
        }
        if newID
        {
            return currentWinIDs[i]
        }
    }
    return 0
}

Add(x, y)
{
    return x + y   ; "Return" expects an expression.
}

^x::
{
    newWinID := 0
    WinGet, winID, list
    ; oldWinIDs := myGetWindowIDs()
    currentWinIDs := []
    MsgBox, % winID
}


^i::
{
    WinMove, A, , 10, 10
}



# Ideen

## File Explorer

Make file explore be like find file in Emacs.

Articles that can help:

- jeeswg's Explorer tutorial
  https://www.autohotkey.com/boards/viewtopic.php?t=31755
- The Magic of AutoHotkey — Part 2
  https://sharats.me/posts/the-magic-of-autohotkey-2/

### Navigation

- Next item
- Previous item

### Recent items 

While the explorer is active it would be a good idea to store the history.
This is like recentf.

### Projectile

Show find file for root and make this recursivly as an option by using probably fd.exe.

#### Get current path

https://www.autohotkey.com/boards/viewtopic.php?f=5&t=38680&p=177407#p177407
https://autohotkey.com/board/topic/80216-excel-get-path-of-current-prior-open-workbooks/

### Extract files at directory

#### With loop

Very slow so far on network drives, try fd.exe, dir is not an option due to .git stuff, gets very slow.

For some reason only folders are shown.

```
Loop, Files, G:\Marketing Services\Marketing-Controlling\SMP Operatives Controlling\SMP 2019\Kosten\*, FDR
{
    fileAttr := A_LoopFileAttrib
    fileName := A_LoopFileFullPath 
    if fileAttr contains H,R,S  ; Skip any file that is either H (Hidden), R (Read-only), or S (System).
    {
        continue  ; Skip this file and move on to the next one.
    }
    match := RegExMatch(fileName, "\\\.git")
    if (match)
    {
        continue
    }
    filesPath .= fileName
}

MsgBox % filesPath
```

#### With fd

Faster but shows a cmd quickly

```
path := "G:\Marketing Services\Marketing-Controlling\SMP Operatives Controlling\SMP 2019\Kosten"
cmd := "fd ... " . """" . path . """"
MsgBox % ComObjCreate("WScript.Shell").Exec(cmd).StdOut.ReadAll()
```

### Move up folder

Probably use splitpath

### File explorer get/set stuff

```
#SingleInstance force
#IfWinActive ahk_class CabinetWClass
q:: ;explorer - select file by name
#IfWinActive ahk_class ExploreWClass
q:: ;explorer - select file by name
;where vName can be a name or path
myName := "fd.exe"
;vName := A_Desktop "\New Text Document.txt"
WinGet, hWnd, ID, A

; The view
; https://docs.microsoft.com/en-us/windows/win32/shell/shellfolderview
; select item
; https://docs.microsoft.com/en-us/windows/win32/shell/shellfolderview-selectitem
; item
; https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
for window in ComObjCreate("Shell.Application").Windows
{
	if (window.HWND = hWnd)
	{
        ; MsgBox % window.Document.Folder.Self.Path
        ; MsgBox % window.document.FocusedItem.Path 
		items := window.document.Folder.Items
        for item in items {
                ; MsgBox, % item.Name
                ; https://docs.microsoft.com/en-us/windows/win32/shell/shellfolderview-selectitem
                ; 1 + 4 + 16
                ; match := (item.Name = myName) ? 21 : 0
                if (item.Name = myName)
                {
                    window.document.SelectItem(item, 21)
                    break
                }
            }
		break
	}
}
oWin := ""
return
#IfWinActive
```
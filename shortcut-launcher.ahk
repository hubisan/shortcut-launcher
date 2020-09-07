; Copyright 2020, Daniel Hubmann

; Author: Daniel Hubmann <hubisan@gmail.com>
; URL: https://github.com/hubisan/shortcut-launcher

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org>

; Changelog
; - 2020-06-24: Added +LV0x10000 to the list view to avoid flickering
;   https://autohotkey.com/board/topic/89323-listview-and-flashing-on-redrawing-or-editing/

#Warn ; Comment when finished
#NoEnv
#SingleInstance force
#NoTrayIcon
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 3

; Get profile configuration.
Loop, Files, %A_ScriptDir%\*.lnk
{
    FileName := A_LoopFileFullPath 
    FileGetShortcut, %FileName%, ProfilePath
    if (!Instr(FileName, "default-profile.lnk"))
    {
        break
    }
}

IniRead, ProfileName, % ProfilePath . "/config.ini", Config, Name
IniRead, ShowRecent, % ProfilePath . "/config.ini", Config, ShowRecent
IniRead, DeleteDuplicatesInRecent, % ProfilePath . "/config.ini", Config, DeleteDuplicatesInRecent
IniRead, DeleteNonExistingInRecent, % ProfilePath . "/config.ini", Config, DeleteNonExistingInRecent

If (ShowRecent == "ERROR" || ShowRecent == "True")
{
    ShowRecent := True
}
Else
{
    ShowRecent := False
}

If (DeleteDuplicatesInRecent == "ERROR" || DeleteDuplicatesInRecent == "True")
{
    DeleteDuplicatesInRecent := True
}
Else
{
    DeleteDuplicatesInRecent := False
}

If (DeleteNonExistingInRecent == "ERROR" || DeleteNonExistingInRecent == "True")
{
    DeleteNonExistingInRecent := True
}
Else
{
    DeleteNonExistingInRecent := False
}

; Global variables
Shortcuts := []
LastSearchString := ""
; ShowRecent := True
; Option: Delete duplicates found in recent files and folders.
; DeleteDuplicatesInRecent := True
; Option: Delete non-existing files and folders in recent.
; DeleteNonExistingInRecent := True

; Setup the GUI including edit box and listview.
Gui, ShortcutLauncher:New, +HwndShortcutsHwnd, Shortcut Launcher
GroupAdd, ShortcutLauncherGroup, ahk_id %ShortcutsHwnd%
; Leaving this here as hwnd was not working at first.
; GroupAdd, ShortcutLauncherGroup, Shortcut Launcher ahk_class AutoHotkeyGUI
Gui, ShortcutLauncher:Color, 091D33, 091D33
Gui, ShortcutLauncher:Font, s10 cDDDDDD, Calibri
Gui, ShortcutLauncher:-Caption -Border
Gui, ShortcutLauncher:Margin, 15, 15
; Add an edit box for the insert the search string.
Gui, ShortcutLauncher:Add, Edit, w1200 h30 +0x200 -VScroll -wrap -E0x200 vSearchString gIncrementalSearch, 
; Create the ListView.
Gui, ShortcutLauncher:Add, ListView, +LV0x10000 r35 w1200 -Multi -Hdr -E0x200 Background091D33 cB6C9DE vShortcutsListView, Name|Target|Filename

; Improve performance by disabling redrawing during load.
GuiControl, -Redraw, ShortcutsListView

; Push shortcuts to array.
GoSub, PushShortcutsFromFolder
GoSub, PushShortcutsFromRecent

; Add shortcuts to listview.
GoSub, AddAll

; Adapt the listview.
LV_Modify(1, "Select Vis") ; Select first and make sure it is in view.
LV_ModifyCol()  ; Auto-size each column to fit its contents.
LV_ModifyCol(3, 0) ; Hide the full filename.
LV_ModifyCol(1, 600) ; Set width of first column.

GuiControl, +Redraw, ShortcutsListView  ; Re-enable redrawing (it was disabled above).
Gui, ShortcutLauncher:Show

Return

PushShortcutsFromFolder:
    ; Get shortcuts from all links in the profile path.
    Loop, Files, %ProfilePath%\*.lnk
    {
        ; Get the folder from the shortcut on your desktop
        FileName := A_LoopFileFullPath 
        FileGetShortcut, %FileName%, Folder

        FileGetAttrib, FolderExists, % Folder
        ; Skip if folder doesn't exist.
        If (FolderExists = "") {
            Continue
        }

        FilePattern := Folder . "\*"

        Loop, Files, %FilePattern%, R 
        {
            If A_LoopFileExt in lnk,url
            {
                ; Must save it to a writable variable for use below. Else it breaks the Loop.
                FileName := A_LoopFileFullPath 
                SplitPath, FileName, Name, Dir, FileExt, FilenameNoExtension 
                If (Dir = Folder)
                {
                    ; If at top dir use empty string as text.
                    Dirname := ""
                }
                Else
                {
                    ; Replace path separator.
                    Dirname := StrReplace(Dir, Folder . "\", "")
                    Dirname := StrReplace(Dirname, "\", " > ")
                }

                FileGetShortcut, %FileName%, OutTarget, OutDir, OutArgs
                If (FileExt = "url")
                {
                    ; If it is an url it actually is a text file with the URL on a line
                    ; on its own starting with URL=. Read the file and extract the url.
                    Loop, read, %Filename%
                    {
                        If (SubStr(A_LoopReadLine, 1, 4) = "URL=")
                        {
                            OutTarget := SubStr(A_LoopReadLine, 5)
                            ; Only Edge can make direct links unlike other browsers, damn you MS.
                            OutTarget := StrReplace(OutTarget, "microsoft-edge:", "(edge) ")
                            break
                        }
                    }
                }
        
                ; For shortcuts using 
                If (RegExMatch(OutTarget . OutArgs, "(chrome|firefox|iexplore)\.exe.*(https.?://.*)$", Match) <> 0)
                {
                    RegExMatch(OutArgs, "") 
                    OutTarget := "(" . Match1 . ") " . Match2
                }
        
                Shortcuts.Push({dir:Dirname, file:FilenameNoExtension, target:OutTarget, filename:Filename})
            }
        }
    }
Return

PushShortcutsFromRecent:
    RecentFiles := []
    Loop, Files, %A_AppData%\Microsoft\Windows\Recent\*.lnk
    {
        FileName := A_LoopFileFullPath 
        FileGetShortcut, %FileName%, OutTarget

        ; Delete if target doesn't exist if file or folder.
        ; Rudimentary check to make sure it is a file or folder.
        ; Anyway, for some reason only links to folder and files are in this directory.
        ; Not sure where the others are you can seen when browsing that folder.
        If (DeleteNonExistingInRecent) {
            If (InStr(OutTarget, "\")) {
                FileGetAttrib, FileExists, % OutTarget
                If (FileExists = "") {
                    FileDelete, %FileName%
                    Continue
                }
            }
        }

        ; Check if duplicates.
        IsDuplicate := False
        for index, value in RecentFiles
        {
            If (OutTarget == value) {
                If (DeleteDuplicatesInRecent) {
                    FileDelete, %FileName%
                }
                IsDuplicate := True   
            break
            }
        }

        If (!IsDuplicate) {
        RecentFiles.Push(OutTarget)
        SplitPath, OutTarget, Fname
            Shortcuts.Push({dir:"Recent", file:Fname, target:OutTarget, filename:Filename})
        }
    }
Return

AddEntry:
    If (value.dir = "") 
    {
    LV_Add("", value.file, value.target, value.filename)
    }
    Else
    {
    LV_Add("", value.dir . " > " . value.file, value.target, value.filename)
    }
Return

AddEntryAtTop:
    If (value.dir = "") 
    {
    LV_Insert(VIPRow, "", value.file, value.target, value.filename)
    }
    Else
    {
    LV_Insert(VIPRow, "", value.dir . " > " . value.file, value.target, value.filename)
    }
Return

AddAll:
    For key, value In Shortcuts 
    {
        If (ShowRecent || (SubStr(TextToCompare, 1, 6) != "Recent"))
        {
            Gosub, AddEntry
        }
    }
Return

IncrementalSearch:
    Gui, ShortcutLauncher:Default
	Gui, ShortcutLauncher:Submit, NoHide
    If (SearchString != LastSearchString) 
    {
        LastSearchString := SearchString
        ; Improve performance by disabling redrawing during load.
        GuiControl, -Redraw, ShortcutsListView  
        ; Clear the list view.
        LV_Delete()
        ; Priotize direct matches.
        ; VIPShortcuts := []
        VIPRow := 1 
        ; Loop through the array and add matching rows to the list view.
        For key, value In Shortcuts 
        {
            TextToCompare := value.dir . " > " . value.file . " " . value.target
            VIPText := value.dir . " > " . value.file 
            If (SearchString != "") 
            {
                ; Create regular expression from search string:
                ;   1. Replace spaces with .* to match any char 0 or more times.
                Regexp := StrReplace(SearchString, " ", ".*")
                ;   2. Make it case insensitive if it contains only lowercase letters. 
                If (! RegExMatch(Regexp, "[A-Z]"))
                {
                    Regexp := "i)" . Regexp
                }
                If (RegExMatch(TextToCompare, Regexp) && (ShowRecent || (SubStr(TextToCompare, 1, 6) != "Recent")))
                {
                    ; Prioritize matches in first column (dir and file) > place at top.
                    ; If (RegExMatch(VIPText, Regexp) && (SubStr(TextToCompare, 1, 6) != "Recent"))
                    If (RegExMatch(VIPText, Regexp))
                    {
                        Gosub, AddEntryAtTop
                        VIPRow++
                    }
                    Else
                    {
                        Gosub, AddEntry
                    }
                }
            } 
            Else If (ShowRecent || (SubStr(TextToCompare, 1, 6) != "Recent"))
            {
                Gosub, AddEntry
            }
        }
        ; Selected the first row and make sure it is visible.
        LV_Modify(1, "Select Vis")
        ; Re-enable redrawing (it was disabled above).
        GuiControl, +Redraw, ShortcutsListView
    }
Return

ToggleRecent:
    Gui, ShortcutLauncher:Default
    ShowRecent := !ShowRecent
    LastSearchString := False
    GoSub, IncrementalSearch
Return

Scroll(num)
{
    If (num > 0)
    {
        Gui, ShortcutLauncher:Default
        NewRow := Min(LV_GetNext() + num, LV_GetCount())
        LV_Modify(NewRow, "Select Vis")
        Return num
    }
    Else If (num < 0)
    {
        Gui, ShortcutLauncher:Default
        NewRow := Max(LV_GetNext() + num, 1) 
        LV_Modify(NewRow, "Select Vis")
        Return num
    }
}

; Global binding to show the GUI.
; ^!+l::
; {
;     Gui, ShortcutLauncher:Show, Restore 
;     Return
; }

; Bindings while GUI is active.

; Remark
; I have remapped capslock to ctrl and then bound capslock to lwin and capslock.
; This unfortunately makes it impossible to repeating a commend while holding
; down capslock as ctrl. 
; https://stackoverflow.com/questions/33732279/autohotkey-repeating-keypress-with-key-modifier-held-down

#IfWinActive, ahk_group ShortcutLauncherGroup
Esc::
^g::
{
	Gui, ShortcutLauncher:Show, Minimize
    Return
}
Up::
^p::
{
    Scroll(-1)
    Return
}
Down::
^n::
{
    Scroll(1)
    Return
}
^u::
{
    ; Clear the edit box 
    Gui, ShortcutLauncher:Default
    GuiControl, , SearchString
    ; SendInput, ^a{Del}
    Return
}
!a::
{
    SendInput, {End}+{Home}
    Return
}
^a::
{ 
    SendInput, {Home} 
    Return
}
^e::
{
    SendInput, {End}
    Return
}
^Backspace::
^+h::
{
    SendInput, ^+{Left}{Backspace}
    Return
}
!d::
{
    SendInput, ^{Del}
    Return
}
^b::
{
    Scroll(-20)
    Return
}
^f::
{
    Scroll(20)
    Return
}
^m::
Enter::
{
    Gui, ShortcutLauncher:Default
    LV_GetText(ShortcutTarget, LV_GetNext(), 3)
    Run %ShortcutTarget%,, UseErrorLevel
    if ErrorLevel
    {
        MsgBox Could not open "%FileDir%\%FileName%".
    }
    Else
    {
        Gui, ShortcutLauncher:Show, Minimize
    }
    Return
}
!o::
{
    ; TODO use the hydra for more actions.
    Gui, ShortcutLauncher:Default
    LV_GetText(ShortcutTarget, LV_GetNext(), 3)
    LV_GetText(Filename, LV_GetNext(), 2)
    FileGetAttrib, Attributes, % Filename
    If (InStr(Attributes, "D"))
    {
        ; Already a dir, run as usual.
        Run %ShortcutTarget%,, UseErrorLevel
    }
    Else
    {
        ; It is a file, use the dir.
        SplitPath, Filename,, OutDir
        Run, explore %OutDir%,, UseErrorLevel
    }
    If ErrorLevel
    {
        MsgBox Could not open "%FileDir%\%FileName%".
    }
    Else
    {
        Gui, ShortcutLauncher:Show, Minimize
    }
    Return

    Return
}

^r::
{
    GoSub, ToggleRecent
    Return
}
^x::
{
    GoSub, GuiClose
    Return
}

GuiClose:  ; When the window is closed, exit the script automatically:
    ExitApp
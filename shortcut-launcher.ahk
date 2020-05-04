; Copyright 2020, Daniel Hubmann

; Author: Daniel Hubmann <hubisan@gmail.com>
; URL: https://github.com/hubisan/shortcut-launcher

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program. If not, see <http://www.gnu.org>

; Check this to make a class
; Beginners OOP with AHK
; https://www.autohotkey.com/boards/viewtopic.php?f=7&t=41332

#NoEnv
#SingleInstance force
#NoTrayIcon
SetTitleMatchMode, 3

; Global variables
Shortcuts := []
LastSearchString := ""
ShowRecent := True

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
Gui, ShortcutLauncher:Add, ListView, r40 w1200 -Multi -Hdr -E0x200 Background091D33 cB6C9DE vShortcutsListView, Name|Target|Filename

; Improve performance by disabling redrawing during load.
GuiControl, -Redraw, ShortcutsListView

; Push shortcuts to array.
GoSub, PushShortcutsFromFolder
GoSub, PushShortcutsFromRecent

; Add shortcuts to listview.
GoSub, AddAll

; Adapt the listview.
LV_Modify(1, "Select Vis") ; Select first and make sure it is in view.
LV_ModifyCol() ; Auto-size each column to fit its contents.
LV_ModifyCol(3, 0) ; Hide the full filename.

GuiControl, +Redraw, ShortcutsListView ; Re-enable redrawing (it was disabled above).
Gui, ShortcutLauncher:Show

Return

PushShortcutsFromFolder:
    ; Get the folder from the shortcut on your desktop
    ShortcutToFolder := A_Desktop . "\shortcut-launcher.lnk"
    FileGetShortcut, %ShortcutToFolder%, ShortcutFolder
    
    If (InStr(FileExist(ShortcutFolder), "D")) 
    {
        FilePattern := ShortcutFolder . "\*"
        Loop, Files, %FilePattern%, R 
        {
            If A_LoopFileExt in lnk,url
            {
                ; Must save it to a writable variable for use below. Else it breaks the Loop.
                FileName := A_LoopFileFullPath 
                SplitPath, FileName, Name, Dir, FileExt, FilenameNoExtension 
                If (Dir = ShortcutFolder)
                {
                    ; If at top dir use empty string as text.
                    Dirname := ""
                }
                Else
                {
                    ; Replace path separator.
                    Dirname := StrReplace(Dir, ShortcutFolder . "\", "")
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
    Else 
    {
        MsgBox % "Shortcut on desktop missing or folder not existing.`n`nSkipping."
    }
Return

PushShortcutsFromRecent:
    RecentFolder := A_AppData . "\Microsoft\Windows\Recent"
    If (InStr(FileExist(RecentFolder), "D")) 
    {
        ; Stuff in recent to not consider, will be more over time.
        ; Add recentBlacklist.txt and recentwhitelist.txt to link folder maybe.
        RecentFilterRegexps := []
        RecentBlacklistFile := ShortcutFolder . "\recentBlacklist.txt"
        Loop, read, %RecentBlacklistFile%
        { 
            RecentFilterRegexps.Push(A_LoopReadLine)
        }

        Loop, Files, %A_AppData%\Microsoft\Windows\Recent\*.lnk
        {

            Filename := A_LoopFileFullPath 
            ; Use a function.
            Filter := False
            for index, value in RecentFilterRegexps
            {
                If (RegExMatch(Filename, value)) {
                    Filter := True   
                break
               }

            }
            If (!Filter) {
                FileGetShortcut, %Filename%, OutTarget
                Shortcuts.Push({dir:"Recent", file:"", target:OutTarget, filename:Filename})
            }
        }
    } 
    Else 
    {
        MsgBox % "Folder with recent files/folders not found. Skipping."
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
        ; Loop through the array and add matching rows to the list view.
        For key, value In Shortcuts 
        {
            TextToCompare := value.dir . " > " . value.file . " " . value.target
            If (SearchString != "") 
            {
                ; Create regular expression from search string:
                ; 1. Replace spaces with .* to match any char 0 or more times.
                Regexp := StrReplace(SearchString, " ", ".*")
                ; 2. Make it case insensitive if it contains only lowercase letters. 
                If (! RegExMatch(Regexp, "[A-Z]"))
                {
                    Regexp := "i)" . Regexp
                }
                If (RegExMatch(TextToCompare, Regexp) && (ShowRecent || (SubStr(TextToCompare, 1, 6) != "Recent")))
                {
                    Gosub, AddEntry
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
; Gui, ShortcutLauncher:Show, Restore 
; Return
; }

; Bindings while GUI is active.

; #IfWinActive, Shortcut Launcher ahk_class AutoHotkeyGUI
#IfWinActive, ahk_group ShortcutLauncherGroup
Esc::
^g::
    {
        Gui, ShortcutLauncher:Minimize
        Return
    }
Up::
^p::
^k::
    {
        Scroll(-1)
        Return
    }
Down::
^n::
^j::
    {
        Scroll(1)
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
            MsgBox % Format("Could not open {:s}", ShortcutTarget)
        }
        Else
        {
            Gui, ShortcutLauncher:Minimize
        }
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
    
    GuiClose: ; When the window is closed, exit the script automatically:
    ExitApp
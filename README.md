# Shortcut-Launcher

An [AutoHotkey](https://www.autohotkey.com/) script for Microsoft Windows to show a GUI that lets you incremental search and open shortcuts.

TODO Add GIF here

The following shortcuts are included:

- shortcuts (\*.lnk) stored in your folder and its subfolders
- web page links (\*.url) stored in your folder and its subfolders
- the recent files/folders automatically stored in `%AppData%\Microsoft\Windows\Recent\`

To specify your **folder** to look in add a shortcut to that folder on your desktop and name it `shortcut-launcher`:

![shortcut launcher on the desktop](img/desktop-shortcut.png)

## Contents

- [Incremental search](#incremental-search)
- [Text used for entries](#text-used-for-entries)
- [Key bindings](#key-bindings)
- [Compiled version](#compiled-version)
- [TODO](#todo)
- [Changelog](#changelog)

## Incremental search

As soon as you enter any key the list is filtered accordingly.

A space in the search string is a wildcard for matching any character 0 or more times. Example: `auto k or um` matches `autohotkey forum`

If the search string contains only lowercase letters the search is performed case insensitive. If the search string contains any uppercase letter the search is done case sensitive.

It combines the text from the 1st column (folder and shortcut name) & 2nd column (target) for the search.

## Text used for entries

The text for each entry in the list view consists of two columns:

- **Path and file base name** - The directory where the shortcut is placed and the name of the shortcut. Path separators are replaced with `>`.
- **Target** - The target of the shortcut. This can be anything you can link to (file, folder, appliation, url).

Example:  
A shortcut named `forum` (forum.lnk) filed in your folder in the subfolder `coding/ahk` which has the target `https://www.autohotkey.com/boards/` will be listed as:

```text
| coding > ahk > forum | https://www.autohotkey.com/boards/ |
```

### Special cases

- **Shortcuts with browser profile** - Shortcuts to open an url with a specific browser profile are recognized and transformed.

  Example:  
  If the target of the shortcut is `%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe --profile-directory="Default" https://www.google.com` the target text is transformed into `(chrome) https://www.google.com`

## Key bindings

For convenience there are multiple bindings per command:

| Key               | Description                          |
| :---------------- | :----------------------------------- |
| <kbd>Ctrl-m</kbd> | open the currently selected shortcut |
| <kbd>Enter</kbd>  | open the currently selected shortcut |
| <kbd>Ctrl-n</kbd> | select next entry                    |
| <kbd>Down</kbd>   | select next entry                    |
| <kbd>Ctrl-p</kbd> | select previous entry                |
| <kbd>Up</kbd>     | select previous entry                |
| <kbd>Ctrl-f</kbd> | scroll down 20 entries               |
| <kbd>Ctrl-b</kbd> | scroll up 20 entries                 |
| <kbd>Ctrl-k</kbd> | clear the input field                |
| <kbd>Ctrl-r</kbd> | toggle showing recent files/folders  |
| <kbd>Ctrl-g</kbd> | minimize                             |
| <kbd>Esc</kbd>    | minimize                             |
| <kbd>Ctrl-x</kbd> | Exit (kill the app)                  |

<kbd>Ctrl-h</kbd> seems to work by default as Backspace in the edit box.

## Compiled version

The compiled script (.exe, 64-bit) is included in this repository. You can compile it
yourself: Use the compiler provided by ahk. Press the win key and then search
for convert .ahk to .exe

## TODO

- [ ] Change subroutines into functions and clean the script. Or rather use a
      class to create a namespace. See the hydra code.
- [ ] Add prefixes like U for url, P for path/folder, F for file or at least URL
- [ ] Extract the profile if one is used for an url. Example:
      `%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe --profile-directory="Default" https://www.tenforums.com`

## Changelog

### No stable release yet

- 2020-06-24 Stop flickering on updating the list view  
  Added +LV0x10000 to the list view to avoid flickering when the list view is updated.  
  https://autohotkey.com/board/topic/89323-listview-and-flashing-on-redrawing-or-editing/

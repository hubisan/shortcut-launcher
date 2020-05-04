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
| <kbd>Ctrl-j</kbd> | select next entry                    |
| <kbd>Down</kbd>   | select next entry                    |
| <kbd>Ctrl-p</kbd> | select previous entry                |
| <kbd>Ctrl-k</kbd> | select previous entry                |
| <kbd>Up</kbd>     | select previous entry                |
| <kbd>Ctrl-f</kbd> | scroll down 20 entries               |
| <kbd>Ctrl-b</kbd> | scroll up 20 entries                 |
| <kbd>Ctrl-r</kbd> | toggle showing recent files/folders  |
| <kbd>Ctrl-g</kbd> | minimize                             |
| <kbd>Esc</kbd>    | minimize                             |
| <kbd>Ctrl-x</kbd> | Exit (kill the app)                  |

<kbd>Ctrl-h</kbd> seems to work by default as Backspace in the edit box.

## Compiled version

To get a compiled script (.exe) just use the compiler provided by ahk. Press the win key and then search for convert .ahk to .exe
I use a compiled version 

## TODO

- [ ] Display error message if folder doesn't exist
- [ ] TODO Change subroutines into functions and clean the script.
- [ ] TODO Maybe refactor all variables to start with `MY`?  
  Most examples do this and there is probably a reason to do so.
- [ ] TODO Add gif animation
- [ ] TODO Add shortcut png with white background (at work)
  
## Changelog

### No stable release yet

- No stable release yet.
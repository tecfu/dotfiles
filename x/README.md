## What this file does:

- Maps Caps Lock to Esc
- Sets sxhkd (Simple X Hotkey Daemon) to remap '<lt;C-j>'rt;, '<lt;C-j>'rt; to the file:
  ```
  $ ~/dotfiles/x/remap_keypresses_in_chrome.sh
  ```

  These files in turn run some xdotool commands. Those commands:
    - Check if the focused window is Google Chrome.
    - If TRUE, send '<lt;C-j>'rt; or '<lt;C-k>'rt; to '<lt;C-b>'rt; or '<lt;C-m>'rt;, both of which are mappable
      in Chrome. 
     
  Then, in your Chrome vim plugin you can bind what you want '<lt;C-j>'rt; and '<lt;C-k>'rt; to
  do to '<lt;C-b>'rt; / '<lt;C-m>'rt; instead.  
   
  This effectively allows us to override Chrome's '<lt;C-j>'rt;,'<lt;C-k>'rt; behavior, which
  browser plugins can't do.


### Installation

- Make sure you install the following:
  
  - xdotool
  - [sxhkd](https://github.com/baskerville/sxhkd)

- Also you'll want to create the following symlinks. Save/remove any existing
conflicts.

```
$ ln -s ~/dotfiles/x/.Xmodmap ~/.Xmodmap
$ ln -s ~/dotfiles/x/sxhkdrc ~/.config/sxhkd/sxhkdrc
```



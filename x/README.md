## What this file does:

- Maps Caps Lock to Esc
- Sets sxhkd (Simple X Hotkey Daemon) to remap C-j, C-j to the file:
  ```
  $ ~/dotfiles/x/remap_keypresses_in_chrome.sh
  ```

  These files in turn run some xdotool commands. Those commands:
    - Check if the focused window is Google Chrome.
    - If TRUE, send C-j or C-k to C-b or C-m, both of which are mappable
      in Chrome. 
     
  Then, in your Chrome vim plugin you can bind what you want C-j and C-k to
  do to C-b / C-m instead.  
   
  This effectively allows us to override Chrome's C-j,C-k behavior, which
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

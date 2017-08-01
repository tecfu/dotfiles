#!/bin/bash

W=`xdotool getactivewindow`
S1=`xprop -id ${W} |awk '/WM_CLASS/{print $4}'`
S2='"google-chrome"'

case "$1" in
  "j")
    #if C-j was passed as an argument AND 
    #the focused window is chrome browser, press C-b
    #otherwise do nothing
    if [ $S1 = $S2 ]; then
      xdotool getwindowfocus key --window %@ ctrl+b
    else
      xdotool getwindowfocus key --window %@ ctrl+j
    fi
    ;;
  "k")_
    #if C-k was passed as an argument AND 
    #the focused window is chrome browser, press C-m
    #otherwise do nothing
    if [ $S1 = $S2 ]; then
      xdotool getwindowfocus key --window %@ ctrl+m
    else
      #xdotool getwindowfocus type --window %@ ctrl+k
      xdotool getwindowfocus key --window %@ ctrl+k
    fi
    ;;
  *)
    #if some other argument, do nothing
    ;;
esac


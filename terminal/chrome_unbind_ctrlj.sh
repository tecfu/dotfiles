#!/bin/bash

W=`xdotool getactivewindow`
S1=`xprop -id ${W} |awk '/WM_CLASS/{print $4}'`
S2='"google-chrome"'

if [ $S1 = $S2 ]; then
	xdotool getwindowfocus key --window %@ ctrl+b
else
	xdotool getwindowfocus key --window %@ ctrl+j
fi

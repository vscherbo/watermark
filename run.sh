#!/bin/sh

#echo '2022-07-01 ЩВА' | pango-view --font='mono' --language=ru_RU --foreground=grey --background=transparent -qo out-stdin-transparent.png /dev/stdin
#pango-view --font='mono' --text='2022-07-01 ЩВА' --language=ru_RU --foreground=grey --background=transparent -qo out-transparent.png
pango-view --rotate=90 --dpi=260 --font='mono' --text='2022-07-01 ЩВА' --language=ru_RU --foreground=grey --background=transparent -qo out-transparent.png

#composite -gravity east out-transparent.png IMG_2881-all-progressive-max90.jpg IMG-plus-watermark.jpg

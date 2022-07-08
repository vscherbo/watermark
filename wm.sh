#!/bin/sh

#SRC=IMG_2881-all-progressive-max90.jpg
SRC=$1
#SRC=AR-1H21-GBN.png
DST=watermark.jpg
WMARK=$(date +'%F ЩВА')

rm -f $DST

#            +distort SRT '4 270 ' \
# not so good          \( -fill red -size 390x300 -background transparent label:"$WMARK" \
width=$(convert $SRC -format "%w" info:)
height=$(convert $SRC -format "%h" info:)

w1=$(($width*92/100))
h1=$(($height*86/100))
kegl=$((width*3/4/45))  # 3/4 - point to pixel factor; 45 - empiric part of width

echo 'w1='$w1
echo 'h1='$h1

convert "$SRC" \
          \( -fill red -pointsize $kegl -background transparent label:"$WMARK" \
             +distort SRT '270 ' \
             +distort Affine "0,0 $w1,$h1" \
          \) -flatten "$DST"

exit 0

convert "$SRC" \
		  -set option:my:right_edge '0,%[fx:h/1.15]' \
          \( -fill red -background transparent label:"$WMARK" \
             +distort SRT '%[fx:w-40],%[fx:h-810] 4 270 %[my:right_edge]' \
          \) -flatten "$DST"

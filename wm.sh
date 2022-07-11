#!/bin/sh

. /usr/local/bin/bashlib

#SRC=IMG_2881-all-progressive-max90.jpg
SRC=$1
src_ext=$(ext $1)
DST=watermark${src_ext}
WMARK=$(date +'%F ЩВА')

rm -f $DST

width=$(convert $SRC -format "%w" info:)
height=$(convert $SRC -format "%h" info:)

color='graya(50%,0.0)'
#color='rgb(220,220,220,0.0)'
#color='rgb(220,220,220)'
#color='red'


if [ $width -ge $height ]
then
	mode=h  # horizontal
	angle='0'
	kegl=$((width*3/4/25))  # 3/4 - point to pixel factor; 25 - empiric part of width
else
	mode=v  # vertical
	angle='270'
	kegl=$((height*3/4/20))  # 3/4 - point to pixel factor; 25 - empiric part of height
fi

# make label image

# AR-1H21-GBN.png  -size 133x133 \
WM_DST="$(namename $1)"_wm"$src_ext"
set -vx
convert -fill $color -stroke 'black' -strokewidth 1 -background transparent \
        +distort SRT $angle \
		-pointsize $kegl \
		label:"$WMARK" \
		-flatten "$WM_DST"
set +vx

convert "$WM_DST" -format "======== %wx%h\n" info:
label_w=$(convert $WM_DST -format "%w" info:)
label_h=$(convert $WM_DST -format "%h" info:)
echo label_w=$label_w
echo label_h=$label_h




if [ $width -ge $height ]
then
	w1=$((${width}-${label_w}))
	h1=$((${height}-${label_h}))
else
	set -vx
	convert -fill $color -stroke 'black' -strokewidth 1 -background transparent \
			+distort SRT $angle \
			-pointsize $kegl \
			-size ${label_h}x${label_h} \
			label:"$WMARK" \
			-flatten "$WM_DST"
	set +vx
	label_w=$(convert $WM_DST -format "%w" info:)
	label_h=$(convert $WM_DST -format "%h" info:)
	echo label_w=$label_w
	echo label_h=$label_h
	shift=0
	w1=$((${width}-$shift-${label_w}/2))
	h1=$((${height}-$shift-${label_h}/2))
	echo 'calculated w1='$w1
	echo 'calculated h1='$h1
	# AR-1H21-GBN.png OK
	#w1=390
	#h1=490
fi
# AR-1H21-GBN.png
#w1=$((${width}-${label_w}/2-10))
#h1=$((${height}-${label_h}/2-10))
#exit 0

# hard coded
# AR-1H21-GBN.png WM 133x133
#w1=460 - unvisible
#h1=590


echo mode=$mode
echo width=$width', w1='$w1
echo height=$height', h1='$h1
echo 'kegl='$kegl
# production
set -vx
convert "$SRC" \
          \( -fill $color -stroke 'black' -strokewidth 1 -background transparent \
			 -pointsize $kegl \
             label:"$WMARK" \
             +distort SRT $angle \
             +distort Affine "0,0 $w1,$h1" \
          \) -flatten "$DST"

set +vx

#			 -border 2x2 -bordercolor transparent \
#-extent $(($label_w+2)) \
#-splice 0x3 \

display "$DST" &


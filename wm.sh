#!/bin/sh

. /usr/local/bin/bashlib

#SRC=IMG_2881-all-progressive-max90.jpg
SRC=$1
src_ext=$(ext $1)
DST=watermark${src_ext}
WMARK=$(date +'%F ЩВА')

rm -f $DST

#            +distort SRT '4 270 ' \
# not so good          \( -fill red -size 390x300 -background transparent label:"$WMARK" \

#convert IMG_2881-all-progressive-max90.jpg -format "%wx%h\n" info:

width=$(convert $SRC -format "%w" info:)
height=$(convert $SRC -format "%h" info:)

#color='rgb(220,220,220,0.50)'
#color='rgb(220,220,220)'
color='red'

label_w=$(($width/5))
label_h=$(($height/20))
echo label_w=${label_w}
echo label_h=${label_h}

if [ $width -ge $height ]
then
	mode=h  # horizontal
	angle='0'
	label_size=${label_w}x${label_h}
	#label_size=${label_w}x
	w1=$((${width}-${label_w}))
	h1=$((${height}-${label_h}-5))
else
	mode=v  # vertical
	angle='270'
	#label_size=x${label_h}
	label_size=${label_w}x${label_w}
	w1=$((${width}-${label_h}-5))
	h1=$((${height}-${label_w}-0))
fi

kegl=$((width*3/4/25))  # 3/4 - point to pixel factor; 45 - empiric part of width


echo mode=$mode
echo width=$width', w1='$w1
echo height=$height', h1='$h1
#echo 'kegl='$kegl
echo 'label_size='$label_size

# watermark top-left corner need
# head_image_B.png 624x324


#          \( -fill $color -pointsize $kegl -background transparent label:"$WMARK" \

set -vx
# make label image
#label_size=48x97 #DEBUG ONLY!!!
#angle=90

#convert -fill $color -stroke 'black' -strokewidth 1 -background transparent \
#        -size $label_size label:"$WMARK" \
#        -distort SRT $angle \
#		-flatten "$DST"
        #+distort SRT $angle \
#exit 0

# production
w1=467
#h1=590
convert "$SRC" \
          \( -fill $color -stroke 'black' -strokewidth 1 -background transparent \
             -size $label_size label:"$WMARK" \
             +distort SRT $angle \
             +distort Affine "0,0 $w1,$h1" \
          \) -flatten "$DST"

exit 0

convert "$SRC" \
		  -set option:my:right_edge '0,%[fx:h/1.15]' \
          \( -fill red -background transparent label:"$WMARK" \
             +distort SRT '%[fx:w-40],%[fx:h-810] 4 270 %[my:right_edge]' \
          \) -flatten "$DST"

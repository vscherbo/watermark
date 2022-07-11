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

#color='rgb(220,220,220,1.0)'
#color='rgb(220,220,220)'
color='red'

# эмпирика: ширина надписи - 1/5, высота надписи - 1/20
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
	h1=$((${height}-${label_h}))
	kegl=$((width*3/4/25))  # 3/4 - point to pixel factor; 25 - empiric part of width
else
	mode=v  # vertical
	angle='270'
	#label_size=x${label_h}
	label_size=${label_w}x${label_w}
	# при повороте label_h и label_w меняются местами
	# при задании label_size
	w1=$((${width}-${label_h}))
	h1=$((${height}-${label_w}))
	#w1=$((${width}-${label_h}+15))
	#h1=$((${height}-${label_w}-2))

	kegl=$((height*3/4/25))  # 3/4 - point to pixel factor; 25 - empiric part of width
	# при задании kegl
	w1=$((${width}*3/4))  # W-W*1/25
	h1=$((${height}-20))  # just test

	# исходя из фактического размера файла с подписью для 100012863_2.png
	#label_w=186
	#label_h=34
	#w1=$((${width}-${label_w}))
	#h1=$((${height}-${label_h}))

fi



# watermark top-left corner need
# head_image_B.png 624x324


#          \( -fill $color -pointsize $kegl -background transparent label:"$WMARK" \

# make label image

#        -size $label_size \
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
w1=$((${width}-${label_w}))
h1=$((${height}-${label_h}))
# AR-1H21-GBN.png
#w1=$((${width}-${label_w}/2-10))
#h1=$((${height}-${label_h}/2-10))
#exit 0

# hard coded
# AR-1H21-GBN.png WM 133x133
#w1=460 - unvisible
#h1=590

#w1=400 OK
#h1=500

echo mode=$mode
echo width=$width', w1='$w1
echo height=$height', h1='$h1
echo 'kegl='$kegl
#echo 'label_size='$label_size
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

exit 0

convert "$SRC" \
		  -set option:my:right_edge '0,%[fx:h/1.15]' \
          \( -fill red -background transparent label:"$WMARK" \
             +distort SRT '%[fx:w-40],%[fx:h-810] 4 270 %[my:right_edge]' \
          \) -flatten "$DST"

#!/bin/bash

############################################
# Clean metadata from .pdf and .jpg files
#
# Depends on:
#		ImageMagick
#		pdftk
#		exiftool
############################################

. /usr/local/bin/bashlib

UPLOAD_DIR=/home/bitrix/www/upload/
[ -d $UPLOAD_DIR ] || UPLOAD_DIR=.
TESTMODE=0	# if 1 - debug (commands not execute, only echo)

WORK_DIR=$(dirname "$0")
FLAG="$WORK_DIR/upload.flag"

MOGRIFY=/usr/bin/mogrify
EXIFTOOL=/usr/bin/exiftool
PDFTK=/usr/bin/pdftk
QPDF=/usr/bin/qpdf

FNAME="$(namename "$0")"
LOGFILE="$WORK_DIR"/"$FNAME".log



CleanMeta () {
  logmsg INFO "checking $1"

  EXT=$(ext "$1")
  case $EXT in
   .jpg|.JPG|.jpeg|.JPEG|.png|.PNG)
		DT=$($EXIFTOOL	-csv -csvDelim '^' -DateTimeOriginal "$1" |tail -1)
		echo "$DT" |grep -q '\^' 
		if [ $? -eq 0 ]
		then  # found '^', save DT
			#DT=$(echo "$DT"|sed 's/.*\^//g')
            DT="${DT/*^/}" 
		else
			DT=
		fi
		logmsg INFO "extracted DateTimeOriginal=$DT"

	    $ECHO $MOGRIFY -define preserve-timestamp=true -strip "$1"
		RC=$?
	    [ $RC -eq 0 ] || logmsg $RC "Strip metadata from $1 finished with rc=$RC"
		if [ "$DT" ]
		then
			$ECHO $EXIFTOOL -P -overwrite_original -DateTimeOriginal="$DT" "$1"
			logmsg $? "restore of original DateTimeOriginal completed"
		fi
   ;;
   .pdf|.PDF)

       $ECHO $QPDF --decrypt "$1" "$1-decrypted"
       RC=$?
       if [ $RC -eq 0 ]
       then
           $ECHO mv "$1-decrypted" "$1"
       else
           logmsg $RC "Failed qpdf on file $1 with rc=$RC" 
       fi

       $ECHO $EXIFTOOL -XMP:All= "$1"
       RC=$?
       if [ $RC -eq 0 ]
       then
           [ -f "$1_original" ] && rm "$1_original"
       else
           logmsg $RC "Failed exiftool on file $1 with rc=$RC"
       fi

       $ECHO $PDFTK "$1" update_info_utf8 "$WORK_DIR/metautf8.txt" output "$1-clean"
       RC=$?
       if [ $RC -eq 0 ]
       then
           $ECHO mv "$1-clean" "$1"
       else
           logmsg $RC "Failed pdftk on file $1 with rc=$RC"
       fi
   ;;
   *) logmsg WARNING "Wrong argument=$1"
  esac
}

cd "$WORK_DIR"

exec 1>>"$LOGFILE"  2>&1

if [ $TESTMODE -eq 1 ]; then
	ECHO=/bin/echo
else
	ECHO=''
fi

logmsg INFO "Started in UPLOAD_DIR=$UPLOAD_DIR"

find $UPLOAD_DIR \( -path "*/rekvizit/*" -prune \) -o \( -path "*/resize_cache/*" -prune \) -o \( -path "*/tmp/*" -prune \) -o -newermm "$FLAG" -type f -regextype posix-egrep \( -iregex '.*\.jp(e|)g$' -o -iregex '.*\.png$' -o -iname '*.pdf' \) -exec printf "%s;" {} \; | while read -r -d ';' file; do
  CleanMeta "$file"
done    

$ECHO touch "$FLAG"

logmsg INFO "Finished"

egrep -v '(image files|INFO)|\[minor\]' "$LOGFILE" |mail -E -s "$FNAME" root

/usr/sbin/logrotate --state logrotate-clean-metadata.state logrotate-clean-metadata.conf


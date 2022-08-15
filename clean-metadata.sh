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

#UPLOAD_DIR=/home/bitrix/www/upload/
#WORK_DIR=/root/bin/CleanMetadata
#FLAG=/root/bin/CleanMetadata/upload.flag
TESTMODE=0	# if 1 - debug (commands not execute, only echo)
UPLOAD_DIR=.
WORK_DIR=.
FLAG=upload.flag

STAT=/usr/bin/stat
SED=/bin/sed
CHOWN=/bin/chown
CHMOD=/bin/chmod
MOGRIFY=/usr/bin/mogrify
EXIFTOOL=/usr/bin/exiftool
PDFTK=/usr/bin/pdftk
QPDF=/usr/bin/qpdf

LOGFILE="$WORK_DIR/CleanMetadata.log"



CleanMeta () {

  EXT=`ext $1`
  case $EXT in
   .jpg|.JPG|.jpeg|.JPEG|.png|.PNG)
		DT=$($EXIFTOOL	-csv -csvDelim '^' -DateTimeOriginal "$1" |tail -1)
		echo "$DT" |grep -q '\^' 
		if [ $? -eq 0 ]
		then  # found '^', save DT
			DT=$(echo $DT|sed 's/.*\^//g')
		else
			DT=
		fi
		logmsg INFO "extracted DateTimeOriginal=$DT"

	    $ECHO $MOGRIFY -define preserve-timestamp=true -strip "$1"
		RC=$?
	    [ $RC -eq 0 ] || logmsg $RC "Strip metadata from $1 finished with rc=$RC"
		if [ $DT ]
		then
			$ECHO $EXIFTOOL -P -overwrite_original -DateTimeOriginal=\'$DT\' "$1"
			logmsg $? "restore of original DateTimeOriginal completed"
		fi
   ;;
   .pdf|.PDF)

       $ECHO $QPDF --decrypt $1 $1-decrypted
       RC=$?
       [ $RC -eq 0 ] && $ECHO mv $1-decrypted $1 || logmsg $RC "Failed qpdf on file $1 with rc=$RC" 

       $ECHO $EXIFTOOL -XMP:All= $1
       RC=$?
       [ $RC -eq 0 ] || logmsg $RC "Failed exiftool on file $1 with rc=$RC" && { [ -f $1_original ] && rm $1_original; }

       $ECHO $PDFTK $1 update_info_utf8 "$WORK_DIR/metautf8.txt" output $1-clean
       RC=$?
       [ $RC -eq 0 ] && $ECHO mv $1-clean $1 || logmsg $RC "Failed pdftk on file $1 with rc=$RC"
   ;;
   *) logmsg WARNING "Wrong argument=$1"
  esac
}


#cd /root/bin/CleanMetadata
cd $WORK_DIR

exec 1>>$LOGFILE  2>&1

if [ $TESTMODE -eq 1 ]; then
	ECHO=/bin/echo
else
	ECHO=''
fi

logmsg INFO "Started"

IFS_SAVE=$IFS
IFS=";"
for f in `find $UPLOAD_DIR -newermm "$FLAG" -type f -regextype posix-egrep \( -iregex '.*\.jp(e|)g$' -o -iregex '.*\.png$' -o -iname '*.pdf' \) -exec printf "%s;" {} \;`
do
  logmsg INFO "checking $f"
  F_OWN=`$STAT --format '%U:%G' "$f"` 
  F_PERM=`$STAT --format '%a' "$f" `
  CleanMeta "$f"
  $ECHO $CHOWN ${F_OWN} ${f}
  $ECHO $CHMOD ${F_PERM} ${f}
done
IFS=$IFS_SAVE

$ECHO touch "$FLAG"

logmsg INFO "Finished"

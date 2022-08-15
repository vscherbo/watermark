#!/bin/bash

# Depends on
# ImageMagick
# pdftk
# exiftool

. /root/.profile
. /root/bin/CleanMetadata/bashlib

WORK_DIR=/home/shopmaster/data/www/shared/upload
#WORK_DIR=/usr/local/backup/home/shopmaster/data/www/shared
MOGRIFY=/usr/local/bin/mogrify
EXIFTOOL=/usr/local/bin/exiftool
PDFTK=/usr/local/bin/pdftk
QPDF=/usr/local/bin/qpdf
#ECHO=echo # debug
ECHO='' # production
LOGFILE=/var/log/CleanMetadata.log
ERRFILE=/var/log/CleanMetadata.err


CleanMeta () {
  EXT=`ext $1`
  case $EXT in
   .jpg|.JPG|.jpeg|.JPEG) #echo -n "$1"
      $MOGRIFY -strip "$1"
      RC=$?
      [ $RC -eq 0 ] || logmsg $RC "Strip metadata from $1 finished with rc=$RC"
   ;;
   .pdf|.PDF) #echo pdf=$1

       $QPDF --decrypt $1 $1-decrypted
       RC=$?
       [ $RC -eq 0 ] && mv $1-decrypted $1 || logmsg $RC "Failed on file $1 with rc=$RC" 

       $EXIFTOOL -XMP:All= $1
       RC=$?
       [ $RC -eq 0 ] || logmsg $RC "Failed on file $1 with rc=$RC" && { [ -f $1_original ] && rm $1_original; }

       $PDFTK $1 update_info_utf8 /root/etc/metautf8.txt output $1-clean
       RC=$?
       [ $RC -eq 0 ] && mv $1-clean $1 || logmsg $RC "Failed on file $1 with rc=$RC"
   ;;
   *) echo Wrong argument=$1
 esac
}

###########################

cd /root/bin/CleanMetadata


  CleanMeta $1

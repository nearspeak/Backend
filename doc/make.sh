#!/bin/sh


CWD=`pwd`

function convert_to_html() {
  OUTFILE=$1.html
  INFILE="raw-${1}.md"

  printf "<html>\n<head><title>Nearspeak Documentation</title></head>\n<body>\n" > $OUTFILE
  markdown --html4tags $INFILE >> $OUTFILE
  printf "</body>\n</html>" >> $OUTFILE

  mv $OUTFILE api/
}

convert_to_html "api-doc"

cd ..

yard -o doc/backend 

cd $CWD

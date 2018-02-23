#!/bin/bash
[ $# -eq 0 ] && { find -type f -exec "$0" {} \; ; exit ; }
[ "$0" = "$*" ] && exit

vim "$*" +TOhtml +"w! /tmp/print.html" +'q!' +'q'
sed -i "s/<pre id='vimCodeElement'>/<pre id='vimCodeElement'><h1>${*//\//\\\/}<\/h1>/g" "/tmp/print.html"
wkhtmltopdf -s A4 --title "$*" --no-background "/tmp/print.html" "/tmp/print.pdf"
lpr -P nili2 -o "InputSlot=AutoSelect" -o "KMDuplex=1Sided" -o "Staple=2Staples" /tmp/print.pdf

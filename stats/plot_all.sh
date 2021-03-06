#! /bin/bash

sleep 5 #give iptraf time to write its data into the log file

WWWDIR=/home/server/www/nico/org/schottelius/tech/stats
TRAFLOG=/root/bin/stats/iptraf.log
WDIR=/root/bin/stats
TODAY=$(/bin/date +%s)  
UDATE=$(/bin/date +%Y%m%d)
NAME=all.gif

SMTP=$(grep "TCP/25" $TRAFLOG|tail -n1|cut -f2 -d","|cut -f2 -d" ")
POP=$(grep "TCP/110" $TRAFLOG|tail -n1|cut -f2 -d","|cut -f2 -d" ")
NAMED=$(grep "UDP/53" $TRAFLOG|tail -n1|cut -f2 -d","|cut -f2 -d" ")

echo "smtp: $SMTP"
echo "pop3: $POP"
echo "named: $NAMED"

if [ -z $NAMED ]; then
  NAMED="0";
fi

if [ -z $SMTP ]; then
  SMTP="0";
fi

if [ -z $POP ]; then
  POP="0";
fi

# archive results

echo $SMTP >> $WDIR/data/smtp-history.$UDATE
echo $POP >> $WDIR/data/pop-history.$UDATE
echo $NAMED >> $WDIR/data/named-history.$UDATE

rrdtool update $WDIR/rrdtool/all.rrd $TODAY:$SMTP:$POP3:$NAMED


#draw the graph


rrdtool graph $WWWDIR/$NAME \
--start -86400 \
--vertical-label "bytes per second" \
-w 600 -h 200 \
DEF:smtp=$WDIR/rrdtool/all.rrd:smtp:AVERAGE \
DEF:pop3=$WDIR/rrdtool/all.rrd:pop3:AVERAGE \
DEF:named=$WDIR/rrdtool/all.rrd:named:AVERAGE \
AREA:smtp#00ff00:"SMTP" \
LINE1:pop3#0000ff:"POP3" \
LINE2:named#ff0000:"DNS"

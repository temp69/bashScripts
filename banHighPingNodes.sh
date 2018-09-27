#!/bin/bash

# Ban nodes which have a high ping time
# config:
# - WALLETDAEMON, what wallet daemon you use.
# - PINGTIME, which will be considered too high default: 10 sec
# - PINGHOST, a host to ping to check if your local client is not lagging, default: www.google.com
# - BANTIME, how long to ban a node  in seconds, default: 72000 sec -> 20 hours
declare -r WALLETDAEMON=magnetd
declare -r PINGTIME=10
declare -r PINGHOST=www.google.com
declare -r BANTIME=72000

# check if computer has a good responds time in general
# the command you have to play with is : ping -w 2 -q www.google.at | cut -d "/" -s -f5 | cut -d "." -f1
# to get the correct info out, it depends on your region "." or "," also f5 can be f4 and so on.... play with it
if [ $(ping -w 2 -q $PINGHOST | cut -d "/" -s -f5 | cut -d "." -f1) -lt $PINGTIME ]; then
        echo "Good response time, checking nodes now..."
else
        echo "Bad response time, will not continoue, check your connection..."
        exit 1;
fi

BANINFO="";
mkdir /tmp/tempBan
cd /tmp/tempBan
$WALLETDAEMON getpeerinfo | grep -E 'addr|pingtime' | grep -v local | split -l 2
for file in $(ls -1); do
        PING=$(cat $file | grep ping | cut -f2 -d":"|cut -f1 -d".")
        IP=$(cat $file | grep addr | cut -f4 -d'"'|cut -f1 -d":")
#       [[ ! -z "$BANINFO" ]] && BANINFO+="\n"
#       BANINFO+="Banned: $IP\t -> ping: $PING";
        if [ $PING -gt $PINGTIME ]; then
                $WALLETDAEMON setban $IP add $BANTIME
                [[ ! -z "$BANINFO" ]] && BANINFO+="\n"
                BANINFO+="Banned: $IP\t -> ping: $PING";
        fi
done
rm -r /tmp/tempBan/
[[ ! -z "$BANINFO" ]] && echo -e $BANINFO || echo "No peer was banned!"

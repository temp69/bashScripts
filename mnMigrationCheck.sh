#!/bin/bash

# When migrating to a new protocol version you can use this
# script to find out how many of your network's masternode's have moved
# config:
# - WALLETDAEMON, set wallet cli to use
# - WALLETVERSION, what walletversion to check

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m'
declare -r WALLETDAEMON='mag-cli'
declare -r WALLETVERSION=70914

while [ 1 ]; do
        nodes=$($WALLETDAEMON masternode list)
	blockCount=$($WALLETDAEMON getblockcount)
        clear
        updated=$(awk -F"$WALLETVERSION" '{print NF-1}' <<< "${nodes}" | grep -E 1 -c)
	enabledNodes=$(awk -F"ENABLED" '{print NF-1}' <<< "${nodes}" | grep -E 1 -c)
	activeNodes=$(awk -F"ACTIVE" '{print NF-1}' <<< "${nodes}" | grep -E 1 -c)
        total=$(awk -F"version" '{print NF-1}' <<< "${nodes}" | grep -E 1 -c)
        percent=$(bc <<< "scale = 4;$updated / $total * 100")

        echo -e "${BLUE} masternode migration monitoring script.${NC}"
        echo
	echo -e "${GREEN} Block: $blockCount${NC}"
        echo -e "${YELLOW} $updated ${BLUE}Masternodes on protocol ${GREEN}${WALLETVERSION} ${BLUE}out of ${YELLOW}$total ${BLUE}[${RED}$percent${BLUE} %]${NC}"
	echo -e "${YELLOW} ENABLED nodes: $enabledNodes"
	echo -e "${YELLOW} ACTIVE nodes: $activeNodes"
	echo
        echo -e "${GREEN} Press CTRL-C to exit. Updated every 25 seconds${NC}"
        sleep 25
done

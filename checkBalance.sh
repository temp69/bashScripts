#!/bin/bash
# config:
# - MASTERNODELIST, add all your masternode addresses in this array
# e.g.: MASTERNODELIST=('MASTERNODE_ADDRESS_1' 'MASTERNODE_ADDRESS_2' 'MASTERNODE_ADDRESS3');
# - QUERYURL, the block explorer you can query for a balance of a given address
# e.g.: QUERYURL='http://blockexplorer.url/ext/getbalance/'
# - MNCOLLATERAL, masternodes collateral
# e.g.: MNCOLLATERAL=10000
# - COINSYMBOL='COUIN';
# e.g.: COINSYMBOL='MAG'

declare -a MASTERNODELIST=('Mf4PcAzarQygmC23GxULDUrLH5c4WVDWVD' 'Mbtz6WLQmkeoQFw4qyS3AGpMg2LEAvE95N' 'Mu8M7mofaysLxvHZxVXGSXW4LYPWE1avor');
declare -r QUERYURL='http://209.250.248.159:3001/ext/getbalance/'
declare -r MNCOLLATERAL=10000;
declare -r COINSYMBOL='MAG'

COUNT=0;
REWARD=0;
for MASTERNODE in "${MASTERNODELIST[@]}"; do
	BALANCE=$(curl -s --connect-timeout 2 "$QUERYURL$MASTERNODE");
	EXITSTATUS=$?
	((COUNT++));
	printf -v NORMCOUNT "%02d" $COUNT
	if [[ "$EXITSTATUS" -eq 0 ]]; then
		INT=${BALANCE%.*};
		REWARD=$((REWARD+INT-$MNCOLLATERAL));
		echo -e "[$NORMCOUNT]$MASTERNODE: $BALANCE / $INT / $((INT-MNCOLLATERAL))";
	else
		echo -e "[$NORMCOUNT]$MASTERNODE: -NA-";
	fi
done
echo -ne "\n$REWARD MAG / $COUNT MASTERNODES = ";
echo "$((REWARD/COUNT)) $COINSYMBOL";

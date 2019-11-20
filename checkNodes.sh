#!/bin/bash

#no arguments
if [[ $# -eq 0 ]]; then
        echo 'Provide a number!';
        exit 1;
fi

if [[ ! $1 == ?(-)+([0-9]) ]]; then
        echo $1' is not a number!';
        exit 1;
fi

# Parse JSON eg.: getinfo and get value for key
# parameters $1 = json string / $2 = key
function parse_json() {
        local json="$1";
        local key="$2";
        local result=$(<<<"$1" awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/\042'$2'\042/){print $(i+1)}}}' | tr -d '"' | sed -e 's/^[[:space:]]*//')
        echo $result;
}

for NUM in $(seq 1 $1); do
        mnResult=;
        mnInfo=;
        mnStatus=;
        mnMessage=;
        if [ $NUM == 1 ]; then
                mnResult=$(mag-cli getinfo | grep -E "blocks|connections");
                mnInfo=$(mag-cli masternode status 2>/dev/null);
                mnStatus=$(parse_json "$mnInfo" "status");
                mnMessage=$(parse_json "$mnInfo" "message");
                echo $mnResult $mnStatus" -> "$mnMessage" == MN01";
                mnResult=$(mag-cli -datadir=/root/.magIPv6 getinfo | grep -E "blocks|connections");
                mnInfo=$(mag-cli -datadir=/root/.magIPv6 masternode status 2>/dev/null);
                mnStatus=$(parse_json "$mnInfo" "status");
                mnMessage=$(parse_json "$mnInfo" "message");
                echo $mnResult $mnStatus" -> "$mnMessage" == MN01_IPv6";
        else
                mnResult=$(mag-cli -datadir=/root/.magIPv6_$NUM getinfo | grep -E "blocks|connections");
                mnInfo=$(mag-cli -datadir=/root/.magIPv6_$NUM masternode status 2>/dev/null);
#               if [ $? -eq 0 ]; then
                        mnStatus=$(parse_json "$mnInfo" "status");
                        mnMessage=$(parse_json "$mnInfo" "message");
#               fi;
                echo $mnResult $mnStatus" -> "$mnMessage" == MN01_IPv6_$NUM";
        fi
done

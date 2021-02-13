#!/bin/bash
DMZ_INTERFACE="eth-dmz"
ALLOW_CONNECTIONS=(
    "10.0.0.100 172.16.0.100 443 tcp"
)
TABLE_NAME="FIREWALL"
CHAIN_NAME="FILTER"

if [ ${UID} -ne 0 ]; then
    echo "root only."
    exit
fi

# flush
nft flush ruleset
nft add table inet ${TABLE_NAME}

# DMZ -> Trust
nft add chain inet ${TABLE_NAME} ${CHAIN_NAME} { type filter hook prerouting priority 0 \; }
nft add rule inet ${TABLE_NAME} ${CHAIN_NAME} ct state related,established accept
for CONNECTIONS in "${ALLOW_CONNECTIONS[@]}"
do
    CONN=(${CONNECTIONS})
    SOURCE=${CONN[0]}
    DEST=${CONN[1]}
    PORT=${CONN[2]}
    PROTO=${CONN[3]}
    nft add rule inet ${TABLE_NAME} ${CHAIN_NAME} ip saddr ${SOURCE} ip daddr ${DEST} ${PROTO} dport ${PORT} accept
done
nft add rule inet ${TABLE_NAME} ${CHAIN_NAME} meta iifname ${DMZ_INTERFACE} drop

# view result
nft list ruleset


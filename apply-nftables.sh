#!/bin/bash

if [ ${UID} -ne 0 ]; then
    echo "root only."
    exit
fi

./set-nftables.sh
nft list ruleset > tee /etc/nftables.conf
systemctl restart nftables
nft list ruleset


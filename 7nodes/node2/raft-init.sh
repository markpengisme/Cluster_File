#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node 2 (permissioned)"
mkdir -p qdata/dd2/{keystore,geth}
cp permissioned-nodes.json qdata/dd2/static-nodes.json
cp permissioned-nodes.json qdata/dd2/
cp keys/key qdata/dd2/keystore
cp raft/nodekey qdata/dd2/geth/nodekey
geth --datadir qdata/dd2 init genesis.json

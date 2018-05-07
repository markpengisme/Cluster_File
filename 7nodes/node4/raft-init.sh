#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node 4 (permissioned)"
mkdir -p qdata/dd4/{keystore,geth}
cp permissioned-nodes.json qdata/dd4/static-nodes.json
cp permissioned-nodes.json qdata/dd4/
cp keys/key qdata/dd4/keystore
cp raft/nodekey qdata/dd4/geth/nodekey
geth --datadir qdata/dd4 init genesis.json

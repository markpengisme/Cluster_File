#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node 3 (permissioned)"
mkdir -p qdata/dd3/{keystore,geth}
cp permissioned-nodes.json qdata/dd3/static-nodes.json
cp permissioned-nodes.json qdata/dd3/
cp keys/key qdata/dd3/keystore
cp raft/nodekey qdata/dd3/geth/nodekey
geth --datadir qdata/dd3 init genesis.json

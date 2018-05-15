#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node 1 (permissioned)"
mkdir -p qdata/dd/{keystore,geth}
cp permissioned-nodes.json qdata/dd/static-nodes.json
cp permissioned-nodes.json qdata/dd/
cp keys/key qdata/dd/keystore
cp raft/nodekey qdata/dd/geth/nodekey
geth --datadir qdata/dd init genesis.json

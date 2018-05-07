#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node 7 (permissioned)"
mkdir -p qdata/dd7/{keystore,geth}
cp permissioned-nodes.json qdata/dd7/static-nodes.json
cp raft/nodekey qdata/dd7/geth/nodekey
geth --datadir qdata/dd7 init genesis.json

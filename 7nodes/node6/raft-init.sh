#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node 6 (permissioned)"
mkdir -p qdata/dd6/{keystore,geth}
cp permissioned-nodes.json qdata/dd6/static-nodes.json
cp raft/nodekey qdata/dd6/geth/nodekey
geth --datadir qdata/dd6 init genesis.json

#!/bin/bash
set -u
set -e

mkdir -p qdata/logs
echo "[*] Starting Constellation Node 6"
./constellation-start.sh

echo "[*] Starting Ethereum Node 6"
ARGS="--raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --emitcheckpoints"
PRIVATE_CONFIG=qdata/c6/tm.ipc nohup geth --datadir qdata/dd6 $ARGS --raftport 50400 --rpcport 22000 --port 21000 2>>qdata/logs/6.log &
echo "Node 6 configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd6/geth.ipc' to attach to the Geth node."


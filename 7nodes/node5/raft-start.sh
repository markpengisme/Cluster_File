#!/bin/bash
set -u
set -e

mkdir -p qdata/logs
echo "[*] Starting Constellation Node 5"
./constellation-start.sh

echo "[*] Starting Ethereum Node 5"
ARGS="--raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --emitcheckpoints"
PRIVATE_CONFIG=qdata/c5/tm.ipc nohup geth --datadir qdata/dd5 $ARGS --raftport 50400 --rpcport 22000 --port 21000 --unlock 0 --password passwords.txt 2>>qdata/logs/5.log &
echo "Node 5 configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd5/geth.ipc' to attach to the Geth node."


#!/bin/bash
set -u
set -e

mkdir -p qdata/logs
echo "[*] Starting Constellation Node"
./constellation-start.sh

echo "[*] Starting Ethereum Node"
ARGS="--raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --emitcheckpoints"
PRIVATE_CONFIG=qdata/c/tm.ipc nohup geth --datadir qdata/dd $ARGS --permissioned --raftport 50400 --rpcport 22000 --port 21000 --unlock 0 --password passwords.txt 2>>qdata/logs/log.log &
echo "Node configured. See 'qdata/logs' for logs, and run e.g. "geth attach qdata/dd/geth.ipc" to attach to the Geth node."
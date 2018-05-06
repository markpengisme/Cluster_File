#!/bin/bash
set -u
set -e

mkdir -p qdata/logs
echo "[*] Starting Constellation nodes"
./constellation-start6.sh

echo "[*] Starting Ethereum nodes"
set -v
ARGS="--raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --emitcheckpoints"
PRIVATE_CONFIG=qdata/c6/tm.ipc nohup geth --datadir qdata/dd6 $ARGS --raftport 50406 --rpcport 22005 --port 21005 2>>qdata/logs/6.log &
set +v

echo
echo "All nodes configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd1/geth.ipc' to attach to the first Geth node."
echo "To test sending a private transaction from Node 1 to Node 7, run './runscript script1.js'"

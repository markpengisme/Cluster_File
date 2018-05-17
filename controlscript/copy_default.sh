NUM_START=$1
NUM_END=$2

for v in `seq $NUM_START $NUM_END`
do
	POD_NAME=$(kubectl get pods --selector=node=node$v | awk 'NR>1 {print $1}')
	kubectl exec $POD_NAME -- bash -c "mkdir -p /home/node/qdata/dd/{keystore,geth}"
	kubectl cp node_default/genesis.json $POD_NAME:/home/node/genesis.json
	kubectl cp node_default/passwords.txt $POD_NAME:/home/node/passwords.txt
	kubectl cp node_default/raft-init.sh $POD_NAME:/home/node/raft-init.sh
	kubectl cp node_default/raft-start.sh $POD_NAME:/home/node/raft-start.sh
	kubectl cp node_default/stop.sh $POD_NAME:/home/node/stop.sh
	echo "Copy folder to node$v ok"
done


## allkey constellation-start.sh
for v in `seq $NUM_START $NUM_END`
do
	GENERATE_DIR="mkdir -p /home/node && cd /home/node"
	GENERATE_KEY='#!/bin/bash
	bootnode -genkey nodekey \
	&& bootnode -writeaddress -nodekey nodekey > enode.key \
	&& echo -ne "\n" | constellation-node --generatekeys=tm \
	&& geth account new --password ./passwords.txt --keystore . \
	&& mv UTC* key'
	IPTEMP_1=$(kubectl get svc nodesvc1 | awk 'NR>1 {print $4}')
	IPTEMP=$(kubectl get svc nodesvc$v | awk 'NR>1 {print $4}')
	GENERATE_CONSTELLATION_START='#!/bin/bash
    set -u
    set -e
    DDIR="qdata/c"
    mkdir -p $DDIR
    mkdir -p qdata/logs
    cp "tm.pub" "$DDIR/tm.pub"
    cp "tm.key" "$DDIR/tm.key"
    rm -f "$DDIR/tm.ipc"
    CMD="constellation-node --url=https://'$IPTEMP':9000/ --port=9000 --workdir=$DDIR --socket=tm.ipc --publickeys=tm.pub --privatekeys=tm.key --othernodes=https://'$IPTEMP_1':9000/"
    $CMD >> "qdata/logs/constellation.log" 2>&1 &
    DOWN=true
    while $DOWN; do
        sleep 0.1
        DOWN=false
        if [ ! -S "qdata/c/tm.ipc" ]; then
                DOWN=true
        fi
    done'
	CREATE_CONSTELLATION_START="echo '$GENERATE_CONSTELLATION_START' > constellation-start.sh && chmod 755 constellation-start.sh"
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c \
		"$GENERATE_DIR && \
		 $GENERATE_KEY && \
		 $CREATE_CONSTELLATION_START "
	echo "Generate allkey and constellation-start.sh in node$v ok"
done
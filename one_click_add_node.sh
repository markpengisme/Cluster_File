#!/bin/bash
re='^[0-9]+$'
while true
do
	echo "How many node do you wanna add:"
	read NUM
	if ! [[ $NUM =~ $re ]] ; then
		echo "error: Not a number"
	else 
		break
	fi
done
EXIST_NUM=$(($(kubectl get deploy | wc -l)-1))
if [ $EXIST_NUM -lt 0 ]
then
    EXIST_NUM=0
fi
TOTAL_NUM=$(($EXIST_NUM+$NUM))
##service
for svc in `seq $(($EXIST_NUM+1)) $TOTAL_NUM`
do 
	echo "
	kind: Service
	apiVersion: v1
	metadata:
	  labels:
	    node: node${svc} 
	  name: nodesvc${svc}
	spec:
	  selector:
	    node: node${svc} 
	  ports:
	  - name: ipc
	    port: 21000
	    targetPort: 21000
	  - name: raftport
	    port: 50400
	    targetPort: 50400
	  - name: rpcport
	    port: 22000
	    targetPort: 22000
	  - name: geth
	    port: 9000
	    targetPort: 9000
	  - name: ui
	    port: 8080
	    targetPort: 8080
	  type: LoadBalancer" > service${svc}.yaml
  	kubectl apply -f service${svc}.yaml
  	rm service${svc}.yaml
done

##deploy
for deploy in `seq $(($EXIST_NUM+1)) $TOTAL_NUM`
do 
	echo "
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  name: node${deploy}
	  labels:
	    app: 7node
	    node: node${deploy}
	spec:
	  nodeSelector:
	    node: node${deploy}
	  replicas: 1
	  selector:
	    matchLabels:
	      app: 7node
	  template:
	    metadata:
	      labels:
	        app: 7node
	        node: node${deploy}
	    spec:
	      containers:
	      - name: 7node
	        image: markpengisme/7node:node
	        imagePullPolicy: Always
	        command: ['/bin/sh']
	        args: ['-c', 'while true; do echo hello; sleep 10;done']
	        ports:
	        - name: raftport
	          containerPort: 50400
	        - name: rpcport
	          containerPort: 22000
	        - name: ipc
	          containerPort: 21000
	        - name: geth
	          containerPort: 9000
	        - name: ui
	          containerPort: 8080" > deploy${deploy}.yaml
	kubectl apply -f deploy${deploy}.yaml
	rm deploy${deploy}.yaml
done

##check ip is ok
for svc in `seq $(($EXIST_NUM+1)) $TOTAL_NUM`
do
	IP_DONE=false
	while [ $IP_DONE = false ]
	do
		IP_DONE=true
		TEMP=$(kubectl get svc nodesvc${svc} | awk 'NR>1 {print $4}')
		if [ "$TEMP" = "<pending>" ]; then
			sleep 2
			IP_DONE=false
			echo "service$svc not ready"
		fi
	done
done


##init dir/gensis.json/empty_passwords.txt/allkey/constellation-start.sh
for v in `seq $(($EXIST_NUM+1)) $TOTAL_NUM`
do
	GENERATE_DIR="mkdir -p /home/node && cd /home/node"
	GENERATE_GENSIS="echo '{
	  \"alloc\": {},
	  \"coinbase\": \"0x0000000000000000000000000000000000000000\",
	  \"config\": {
	    \"homesteadBlock\": 0,
	    \"chainId\": 1,
	    \"eip155Block\": null,
	    \"eip158Block\": null,
	    \"isQuorum\": true
	  },
	  \"difficulty\": \"0x0\",
	  \"extraData\": \"0x0000000000000000000000000000000000000000000000000000000000000000\",
	  \"gasLimit\": \"0xE0000000\",
	  \"mixhash\": \"0x00000000000000000000000000000000000000647572616c65787365646c6578\",
	  \"nonce\": \"0x0\",
	  \"parentHash\": \"0x0000000000000000000000000000000000000000000000000000000000000000\",
	  \"timestamp\": \"0x00\"
	}' > genesis.json"
	GENERATE_PASSWORD="echo '' > passwords.txt"
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
		 $GENERATE_GENSIS && \
		 $GENERATE_PASSWORD && \
		 $GENERATE_KEY && \
		 $CREATE_CONSTELLATION_START "
done

##generate permissioned-nodes.json
for v in `seq 1 $TOTAL_NUM`
do
  eval IPTEMP_$v=$(kubectl get svc nodesvc$v | awk 'NR>1 {print $4}')
  eval ENODE_$v=$(kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "cat /home/node/enode.key")
  eval COMBINE="enode://"$(echo \$ENODE_$v)"@"$(echo \$IPTEMP_$v)"21000?discport=0\"&\"raftport=50400"
  echo $COMBINE >> 123.txt
done
## sed
#
# add " in head and tail, 
# delete last line last character,
# add '[' in first line
# add ']' in last line
##
sed -e 's/.*/"&",/' -e '$ s/.$//' -e '1i[' -e '$a]' 123.txt > permissioned-nodes.json
rm 123.txt
for v in `seq $TOTAL_NUM`
do
    PERMISSION=$(cat permissioned-nodes.json)
    CREATE='cd home/node && echo '${PERMISSION}'> permissioned-nodes.json'
    kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$CREATE"
    echo "No.$v permissioned-nodes ok"
done

##init raft.init.sh/raft-start.sh/stop.sh
for v in `seq $(($EXIST_NUM+1)) $TOTAL_NUM`
do
	GENERATE_RAFT_INIT='#!/bin/bash
	set -u
	set -e

	echo "[*] Cleaning up temporary data directories"
	rm -rf qdata
	mkdir -p qdata/logs

	echo "[*] Configuring node"
	mkdir -p qdata/dd/{keystore,geth}
	cp permissioned-nodes.json qdata/dd/static-nodes.json
	cp permissioned-nodes.json qdata/dd/
	cp key qdata/dd/keystore
	cp nodekey qdata/dd/geth/nodekey
	geth --datadir qdata/dd init genesis.json
	'
	GENERATE_RAFT_START='#!/bin/bash
	set -u
	set -e

	mkdir -p qdata/logs
	echo "[*] Starting Constellation Node"
	./constellation-start.sh

	echo "[*] Starting Ethereum Node"
	ARGS="--raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --emitcheckpoints"
	PRIVATE_CONFIG=qdata/c/tm.ipc nohup geth --datadir qdata/dd $ARGS --permissioned --raftport 50400 --rpcport 22000 --port 21000 --unlock 0 --password passwords.txt 2>>qdata/logs/log.log &
	echo "Node configured. See 'qdata/logs' for logs, and run e.g. "geth attach qdata/dd/geth.ipc" to attach to the Geth node."
	'
	STOP_ALL='killall geth bootnode constellation-node'

	CREATE_RAFT_INIT="echo '$GENERATE_RAFT_INIT' > raft-init.sh && chmod 755 raft-init.sh"
	CREATE_RAFT_START="echo '$GENERATE_RAFT_START' > raft-start.sh && chmod 755 raft-start.sh"
	CREATE_STOP_ALL="echo '$STOP_ALL' > stop.sh && chmod 755 stop.sh"

	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c \
		"cd /home/node && \
		 $CREATE_RAFT_INIT && \
		 $CREATE_RAFT_START && \
		 $CREATE_STOP_ALL "
done

##blockchain development
for v in `seq $(($EXIST_NUM+1)) $TOTAL_NUM`
do
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c \
		"cd home/node && \
	  	 ./stop.sh && \
	  	 ./raft-init.sh && \
	  	 ./raft-start.sh"
    echo "No.$v develop key ok"
done



#!/bin/bash
echo "Quorum in k8s Start:"
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
EXIST_NUM=$(($(kubectl get deploy | wc -l)-2))
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
  type: LoadBalancer
  " > service${svc}.yaml
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
          containerPort: 8080
  " > deploy${deploy}.yaml
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

##generate key
for svc in `seq $(($EXIST_NUM+1)) $TOTAL_NUM`
do
	GENERATE_KEY='#!/bin/bash
	bootnode -genkey bootnode.key \
	&& bootnode -writeaddress -nodekey bootnode.key > enode.key \
	&& echo -ne '\n' | constellation-node --generatekeys=tm \
	&& geth account new --password ./passwords.txt --keystore . \
	&& mv UTC* key'
done


##generate constellation-start.sh
for svc in `seq $(($EXIST_NUM+1)) $TOTAL_NUM`
do
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
    $CMD >> "qdata/logs/constellation$i.log" 2>&1 &
    DOWN=true
    while $DOWN; do
        sleep 0.1
        DOWN=false
        if [ ! -S "qdata/c/tm.ipc" ]; then
                DOWN=true
        fi
    done'

	CREATE="echo '$GENERATE_CONSTELLATION_START' > constellation-start.sh && chmod 755 constellation-start.sh"
done


##generate permissioned-nodes.json
for v in `seq 1 $NUM`
do
  IPTEMP_$v=$(kubectl get svc nodesvc1 | awk 'NR>1 {print $4}')
  ENODE_$v=$(kubectl get svc nodesvc1 | awk 'NR>1 {print $4}')
  ENODE_1="enode://ac6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef@$IPTEMP_1:21000?discport=0&raftport=50400"
 
done

for v in `seq 1 $NUM`
do
    GENERATE_PERMISSION_START="[
      \"$ENODE_1\",
      \"$ENODE_2\",
      \"$ENODE_3\",
      \"$ENODE_4\",
      \"$ENODE_5\",
      \"$ENODE_6\",
      \"$ENODE_7\"
    ]"
    CREATE="cd home/node$v && echo '$GENERATE_PERMISSION_START' > permissioned-nodes.json"
    kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$CREATE"
    echo "No.$v permissioned-nodes ok"
done
##blockchain development

kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "cd home/node$v && $GENERATE_KEY"
    echo "No.$v key ok"




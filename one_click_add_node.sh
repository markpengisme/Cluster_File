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
EXIST_NUM=$(($(kubectl get svc | wc -l)-2))
##service
for svc in `seq $(($EXIST_NUM+1)) $(($EXIST_NUM+$NUM))`
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
for deploy in `seq $(($EXIST_NUM+1)) $(($EXIST_NUM+$NUM))`
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
        image: markpengisme/7node:node_add
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
for svc in `seq $(($EXIST_NUM+1)) $(($EXIST_NUM+$NUM))`
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
##generate constellation-start.sh


##generate permissioned-nodes.json


##blockchain development


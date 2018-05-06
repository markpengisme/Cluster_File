#!/bin/bash
echo "How many node do you wanna create:"
read NUM

##service
pushd svc >/dev/null
for svc in `seq $NUM`
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
  type: LoadBalancer
  " > service${svc}.yaml
  kubectl apply -f service${svc}.yaml
done
popd >/dev/null

##deploy
pushd deploy >/dev/null
for deploy in `seq $NUM`
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
        image: markpengisme/7node:node${deploy}
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
        volumeMounts:
        - mountPath: /home
          name: git-volume
      volumes:
      - name: git-volume
        gitRepo:
          repository: 'https://github.com/markpengisme/Cluster_File.git'
  " > deploy${deploy}.yaml
  kubectl apply -f deploy${deploy}.yaml
done
popd >/dev/null

##check ip is ok
for svc in `seq $NUM`
do
	IP_DONE=false
	while [ $IP_DONE = false ]
	do
		sleep 1
		IP_DONE=true
		TEMP=$(kubectl get svc nodesvc${svc} | awk 'NR>1 {print $4}')
		if [ "$TEMP" = "<pending>" ]; then
			IP_DONE=false
			echo "service$svc還沒好建立好"
		fi
	done
done

##exec nod1


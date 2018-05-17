NUM_START=$1
NUM_END=$2
for svc in `seq $NUM_START $NUM_END`
do 
	echo "kind: Service
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
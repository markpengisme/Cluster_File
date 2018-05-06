NUM=$1
for (( v = 1 ; v < $NUM+1 ; v++ ))
do
	RUN="cd home/node$v && sh run.sh"
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$RUN"
done
NUM=$1
echo "\n========clean all node start=======\n"
for v in `seq 1 $NUM`
do
	RUN="cd home/node$v && sh stop.sh"
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$RUN" &
done

for v in `seq 1 $NUM`
do
	echo "\n========raft $v start=======\n"
	RUN="cd home/node$v && sh run.sh"
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$RUN"
done
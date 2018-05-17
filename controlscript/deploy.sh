NUM_START=$1
NUM_END=$2
for v in `seq $NUM_START $NUM_END`
do
  kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c \
  "cd home/node && ./stop.sh"
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c \
	"cd home/node && ./raft-init.sh && ./raft-start.sh &" &
  echo "No.$v node deploy ok"
done

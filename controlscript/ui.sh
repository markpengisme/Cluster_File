NUM_START=$1
NUM_END=$2
for v in `seq $NUM_START $NUM_END`
do
	echo "open node$v UI"
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c \
	"cd home/ && rm -rf data/geth && export USER=root && gosu root java -jar cakeshop.war &" &
done


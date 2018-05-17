rm node_default/permissioned-nodes.json 2> /dev/null
NUM_START=$1
NUM_END=$2
echo "Generate permissioned-nodes.json in local"
for v in `seq 1 $NUM_END`
do
  eval IPTEMP_$v=$(kubectl get svc nodesvc$v | awk 'NR>1 {print $4}')
  eval ENODE_$v=$(kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "cat /home/node/enode.key")
  eval COMBINE="enode://"$(echo \$ENODE_$v)"@"$(echo \$IPTEMP_$v)":21000?discport=0\"&\"raftport=50400"
  echo $COMBINE >> node_default/permissioned-nodes.json
done
## sed
#
# add \" in head and \", in tail, 
# delete last line last character,
# add '[' in first line
# add ']' in last line
##
sed -i -e 's/.*/"&",/' -e '$ s/.$//' -e '1i[' -e '$a]' node_default/permissioned-nodes.json


## copy permissioned-node.json
for v in `seq 1 $NUM_END`
do
	POD_NAME=$(kubectl get pods --selector=node=node$v | awk 'NR>1 {print $1}')
	kubectl cp node_default/permissioned-nodes.json $POD_NAME:/home/node/permissioned-nodes.json
	kubectl cp node_default/permissioned-nodes.json $POD_NAME:/home/node/qdata/dd/static-nodes.json
	kubectl cp node_default/permissioned-nodes.json $POD_NAME:/home/node/qdata/dd/
	echo "copy permissioned-nodes to node$v ok"
done

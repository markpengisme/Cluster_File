v=1
POD_NAME=$(kubectl get pods --selector=node=node$v | awk 'NR>1 {print $1}')
kubectl cp node_default/runscript.sh $POD_NAME:/home/node/runscript.sh
kubectl cp node_default/script.js $POD_NAME:/home/node/script.js
kubectl exec $POD_NAME -- bash -c "cd home/node && ./runscript.sh script.js"
	
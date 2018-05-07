NUM=$1
for svc in `seq $NUM`
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
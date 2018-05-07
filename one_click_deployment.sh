#!/bin/bash
echo "Quorum in k8s Start:"
re='^[0-9]+$'
while true
do
	echo "How many node do you wanna create(MAX=7):"
	read NUM
	if ! [[ $NUM =~ $re ]] ; then
		echo "error: Not a number"
	elif [ $NUM -gt "7" ]; then
		echo "Number greater than 7"
	else 
		break
	fi
done

##service
sh script/create_service.sh $NUM

##deploy
sh script/create_deploy.sh $NUM

##check ip is ok
sh script/check_ip.sh $NUM

##generate constellation-start.sh
sh script/generate_constellation-start.sh $NUM

##generate permissioned-nodes.json
sh script/generate_permissioned-nodes.sh $NUM

##blockchain development
sh script/raft.sh $NUM

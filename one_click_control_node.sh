#!/bin/bash
re='^[0-9]+$'
while true
do
	echo "================="
	echo "Please enter 1~5"
	echo "1.Quick deployment N's node"
	echo "2.Quick add N's node"
	echo "3.Delete node"
	echo "4.Change UI"
	echo "5.Block generator"
	read FEATURE
	if ! [[ $FEATURE =~ $re ]] ; then
		echo -e "error: Not a number\n"
	elif [ $FEATURE -lt 1 ] || [ $FEATURE -gt 5 ] ; then
		echo -e "error: Please input 1~5\n"
	else 
		break
	fi
done

if [ $FEATURE -eq 1 ] ; then
	while true
	do
		echo "How many node do you wanna create:"
		echo "Please confirm that you have enough space and global IP addresses"
		read NUM_END
		if ! [[ $NUM_END =~ $re ]] ; then
			echo "error: Not a number"
		else 
			NUM_START=1
			break
		fi
	done
elif [ $FEATURE -eq 2 ] ; then
	#get last node number 
	EXIST_NUM=$(kubectl get deploy | awk \
	'BEGIN {max = 0} {if (substr($1,5,4)+0 > max+0) max=substr($1,5,4)} END {print max}')
	while true
	do
		echo "How many node do you wanna add:"
		echo "Please confirm that you have enough space and global IP addresses"
		read NUM
		if ! [[ $NUM =~ $re ]] ; then
			echo "error: Not a number"
		else 
			NUM_START=$(($EXIST_NUM+1))
			NUM_END=$(($EXIST_NUM+$NUM))
			break
		fi
	done
	
elif [ $FEATURE -eq 3 ] ; then
	while true
	do
		echo "What number node do you wanna delete:"
		echo -e "eg:\n input:1 3 5 7\n delete node1,3,5,7"
		read NUM
		for var in ${NUM[@]}
		do
			kubectl delete svc nodesvc$var 
			kubectl delete deploy node$var
			echo "delete node$var"
		done
		break
	done
	exit 0
elif [ $FEATURE -eq 4 ] ; then
	echo "What node do you wanna connect to ui:"
	echo -e "eg:\n input:1\n connect ui to node1"
	read NUM
	sh controlscript/create_ui.sh $NUM
	exit 0
elif [ $FEATURE -eq 5 ] ; then
	echo "Start create block:"
	sh controlscript/create_block.sh 
	exit 0
else
	echo "some error"
	exit 0 
fi

##service
sh controlscript/create_service.sh $NUM_START $NUM_END

##deploy
sh controlscript/create_deployment.sh $NUM_START $NUM_END

##check ip is ok
sh controlscript/check_ip.sh $NUM_START $NUM_END

## copy passwords	raft-init	raft-start	stop
sh controlscript/copy_default.sh $NUM_START $NUM_END

##generate permissioned-nodes.json
NUM=$(kubectl get deploy | awk '{print substr($1,5,4)}')
sh controlscript/generate_permissioned.sh $NUM

##blockchain deploy
sh controlscript/deploy.sh $NUM_START $NUM_END

##creat ui
if [ $FEATURE -eq 1 ] ; then
	sh controlscript/create_ui.sh 1
fi

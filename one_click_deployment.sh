#!/bin/bash
echo "How many node do you wanna create:"
read NUM

##service
sh script/create_service.sh $NUM

##deploy
sh script/create_deploy.sh $NUM

##check ip is ok
sh script/check_ip.sh $NUM

##generate constellation-start.sh
sh script/generate_constellation-start.sh $NUM

##generate permissioned-nodes.json

##blockchain development
sh script/raft.sh $NUM

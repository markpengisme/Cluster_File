#!/bin/bash
echo "How many node do you wanna create:"
read NUM

##service
sh script/create_service $NUM

##deploy
sh script/create_deploy $NUM

##check ip is ok
sh script/check_ip $NUM

##generate constellation-start
sh script/generate_constellation-start $NUM

NUM=$1
IPTEMP_1=$(kubectl get svc nodesvc1 | awk 'NR>1 {print $4}')
for (( v = 1 ; v < $NUM+1 ; v++ ))
do
    IPTEMP=$(kubectl get svc nodesvc$v | awk 'NR>1 {print $4}')
    GENERATE_CONSTELLATION_START='#!/bin/bash
    set -u
    set -e

    for i in '$v'
    do
        DDIR="qdata/c$i"
        mkdir -p $DDIR
        mkdir -p qdata/logs
        cp "keys/tm.pub" "$DDIR/tm.pub"
        cp "keys/tm.key" "$DDIR/tm.key"
        rm -f "$DDIR/tm.ipc"
        CMD="constellation-node --url=https://'$IPTEMP':9000/ --port=9000 --workdir=$DDIR --socket=tm.ipc --publickeys=tm.pub --privatekeys=tm.key --othernodes=https://'$IPTEMP_1':9000/"
        echo "$CMD >> qdata/logs/constellation$i.log 2>&1 &"
        $CMD >> "qdata/logs/constellation$i.log" 2>&1 &
    done

    DOWN=true
    while $DOWN; do
        sleep 0.1
        DOWN=false
        for i in '$v'
        do
        if [ ! -S "qdata/c$i/tm.ipc" ]; then
                DOWN=true
        fi
        done
    done'

    CREATE="cd home/node$v && echo '$GENERATE_CONSTELLATION_START' > constellation-start.sh && chmod 755 constellation-start.sh"
    kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$CREATE"
    echo "No.$v constellation-start ok"
done


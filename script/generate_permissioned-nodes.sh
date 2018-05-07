NUM=$1
for v in `seq 1 $NUM`
do
  case $v in
    '1')
      IPTEMP_1=$(kubectl get svc nodesvc1 | awk 'NR>1 {print $4}')
      ENODE_1="enode://ac6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef@$IPTEMP_1:21000?discport=0&raftport=50400"
      ;;
    '2')
      IPTEMP_2=$(kubectl get svc nodesvc2 | awk 'NR>1 {print $4}')
      ENODE_2="enode://0ba6b9f606a43a95edc6247cdb1c1e105145817be7bcafd6b2c0ba15d58145f0dc1a194f70ba73cd6f4cdd6864edc7687f311254c7555cc32e4d45aeb1b80416@$IPTEMP_2:21000?discport=0&raftport=50400"
      ;;
    '3')
      IPTEMP_3=$(kubectl get svc nodesvc3 | awk 'NR>1 {print $4}')
      ENODE_3="enode://579f786d4e2830bbcc02815a27e8a9bacccc9605df4dc6f20bcc1a6eb391e7225fff7cb83e5b4ecd1f3a94d8b733803f2f66b7e871961e7b029e22c155c3a778@$IPTEMP_3:21000?discport=0&raftport=50400"
      ;;
    '4')
      IPTEMP_4=$(kubectl get svc nodesvc4 | awk 'NR>1 {print $4}')
      ENODE_4="enode://3d9ca5956b38557aba991e31cf510d4df641dce9cc26bfeb7de082f0c07abb6ede3a58410c8f249dabeecee4ad3979929ac4c7c496ad20b8cfdd061b7401b4f5@$IPTEMP_4:21000?discport=0&raftport=50400"
      ;;
    '5')
      IPTEMP_5=$(kubectl get svc nodesvc5 | awk 'NR>1 {print $4}')
      ENODE_5="enode://3701f007bfa4cb26512d7df18e6bbd202e8484a6e11d387af6e482b525fa25542d46ff9c99db87bd419b980c24a086117a397f6d8f88e74351b41693880ea0cb@$IPTEMP_5:21000?discport=0&raftport=50400"
      ;;
    '6')
      IPTEMP_6=$(kubectl get svc nodesvc6 | awk 'NR>1 {print $4}')
      ENODE_6="enode://eacaa74c4b0e7a9e12d2fe5fee6595eda841d6d992c35dbbcc50fcee4aa86dfbbdeff7dc7e72c2305d5a62257f82737a8cffc80474c15c611c037f52db1a3a7b@$IPTEMP_6:21000?discport=0&raftport=50400"
      ;;
    '7')
      IPTEMP_7=$(kubectl get svc nodesvc7 | awk 'NR>1 {print $4}')
      ENODE_7="enode://239c1f044a2b03b6c4713109af036b775c5418fe4ca63b04b1ce00124af00ddab7cc088fc46020cdc783b6207efe624551be4c06a994993d8d70f684688fb7cf@$IPTEMP_7:21000?discport=0&raftport=50400"
      ;;
    '*')
      echo "error"
      ;;
  esac
done

for v in `seq 1 $NUM`
do
    GENERATE_PERMISSION_START="{\"$ENODE_1\",\"$ENODE_2\",\"$ENODE_3\",\"$ENODE_4\",\"$ENODE_5\",\"$ENODE_6\",\"$ENODE_7\"}"
    CREATE="cd home/node$v && echo '$GENERATE_PERMISSION_START' > permissioned-nodes.json"
    kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$CREATE"
    echo "No.$v permissioned-nodes ok"
done
NUM=$1
echo "kind: Service
apiVersion: v1
metadata:
  name: ui-svc
  labels:
    ui: ui-svc 
spec:
  selector:
    ui: ui
  ports:
  - name: ui
    port: 8080
    targetPort: 8080
  type: LoadBalancer" > ui_svc.yaml
kubectl apply -f ui_svc.yaml
rm ui_svc.yaml

echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: ui
  labels:
    ui: ui
spec:
  replicas: 1
  selector:
    matchLabels:
      ui: ui
  template:
    metadata:
      labels:
        ui: ui
    spec:
      containers:
      - name: ui
        image: markpengisme/7node:cake
        imagePullPolicy: Always
        command: ['/bin/sh']
        args: ['-c', 'while true; do echo hello; sleep 10;done']
        ports:
        - name: ui
          containerPort: 8080" > ui_deploy.yaml
kubectl apply -f ui_deploy.yaml
rm  ui_deploy.yaml

IP=$(kubectl get svc  | awk '{if(substr($1,8,4)=='$NUM'){print $4}}')
sed -i "26s/.*/geth.url=http\\\:$IP\\\:22000/" node_default/application.properties
UI_NAME=$(kubectl get pods --selector=ui=ui | awk 'NR>1 {print $1}')
kubectl cp node_default/application.properties $UI_NAME:/home/data/local/application.properties
echo "Copy application.properties to ui ok"
kubectl exec $UI_NAME -- bash -c 'rm -rf home/data/geth && fuser -k 8080/tcp'
kubectl exec $UI_NAME -- bash -c \
  'cd home/ && USER=root && gosu root java -jar cakeshop.war' &

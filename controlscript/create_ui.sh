echo "kind: Service
apiVersion: v1
metadata:
  name: UI_svc
  labels:
    ui: ui_svc 
spec:
  selector:
    ui: UI
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
  name: UI_deploy
  labels:
    ui: ui_deploy
spec:
  replicas: 1
  template:
    metadata:
      labels:
        ui: UI
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

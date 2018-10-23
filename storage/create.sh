echo "create storageclass gp2"
kubectl apply -f storageclass.yml 

echo "create storageclass cheap"
kubectl apply -f storageclass_cheap.yml 

echo "create persistentvolumeclaim myclaim"
kubectl apply -f pvc.yml 

echo "create pod with persitant volume"
kubectl apply -f pod.yml 

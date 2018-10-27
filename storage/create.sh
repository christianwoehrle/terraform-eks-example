echo "create storageclass gp2"
kubectl apply -f storageclass.yml 

echo "create storageclass cheap"
kubectl apply -f storageclass_cheap.yml 

echo "to create a pvc, execute kubectl apply -f pvc.yml "
echo "Don't forget to delete it afterwards"
#echo "create persistentvolumeclaim myclaim"
#kubectl apply -f pvc.yml 

echo "To attach the pvc to a pod, execute kubectl apply -f pod.yml"
echo "Don't forget to delete the pod if you want to delete the pvc"

#echo "create pod with persitant volume"
#kubectl apply -f pod.yml 

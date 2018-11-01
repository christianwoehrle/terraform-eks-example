#helm install --name chrissi-kafka incubator/kafka

## Kafka Operator

kubectl create namespace kafka 
curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.8.2/strimzi-cluster-operator-0.8.2.yaml   | sed 's/namespace: .*/namespace: kafka/'   | kubectl -n kafka apply -f -


#kubectl apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/0.8.2/examples/kafka/kafka-persistent.yaml -n kafka
kubectl -n default exec testclient -- /usr/bin/kafka-topics --zookeeper chrissi-kafka-zookeeper:2181 --list
kubectl -n default exec -ti testclient -- /usr/bin/kafka-console-consumer --bootstrap-server chrissi-kafka:9092 --topic test1 --from-beginning
kubectl logs my-cluster-kafka-0/volume-munt-hack -n kafka



helm init
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'


helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install --name my-kafka incubator/kafka


# TEstclient starten
kubectl apply -f pod_testclient.yml 

kubectl -n default exec testclient -- /usr/bin/kafka-topics --zookeeper my-kafka-zookeeper.default.svc.cluster.local:2181 --list

kubectl -n default exec testclient -- /usr/bin/kafka-topics --zookeeper my-kafka-zookeeper.default.svc.cluster.local:2181 --create --topic foo  --partitions 3 --replication-factor 1


kubectl -n default exec -ti testclient -- /usr/bin/kafka-console-consumer --bootstrap-server my-kafka.default.svc.cluster.local:9092 --topic foo --from-beginning

kubectl -n default -ti exec testclient -- /usr/bin/kafka-console-producer --broker-list  my-kafka.default.svc.cluster.local:9092 --topic foo


# schema registry installieren

helm install --name mysr -f values.yaml incubator/schema-registry 
kubectl get po
export POD_NAME=$(kubectl get pods --namespace default -l "app=schema-registry,release=mysr" -o jsonpath="{.items[0].metadata.name}")
echo $POD_NAME
kubectl port-forward $POD_NAME 8080:8081

 curl localhost:8080
{}dwx1946@dwp01191:~/git-repo/christianwoehrle/terraform-eks-example/kafka$ 



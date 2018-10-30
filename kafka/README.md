#helm install --name chrissi-kafka incubator/kafka

## Kafka Operator

kubectl create namespace kafka 
kubectl apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/0.8.2/examples/kafka/kafka-persistent.yaml -n kafka
kubectl -n default exec testclient -- /usr/bin/kafka-topics --zookeeper chrissi-kafka-zookeeper:2181 --list
kubectl -n default exec -ti testclient -- /usr/bin/kafka-console-consumer --bootstrap-server chrissi-kafka:9092 --topic test1 --from-beginning
kubectl logs my-cluster-kafka-0/volume-munt-hack -n kafka



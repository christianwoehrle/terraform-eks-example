# EKS Getting Started Guide Configuration

taken from

https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/02-path-working-with-clusters/201-cluster-monitoring

## Install thePrometheus Operator
```
kubectl apply -f prometheus-bundle.yaml
```

Check status
```
kubectl rollout status deployment/prometheus-operator -n monitoring
```
```
kubectl apply -f prometheus.yaml
```
```
kubectl get po -l prometheus=prometheus -n monitoring
```
```
kubectl port-forward $(kubectl get po -l prometheus=prometheus -n monitoring -o jsonpath={.items[0].metadata.name}) 9090 -n monitoring
```

Open Browser at localhost:9090

```
kubectl apply -f grafana-bundle.yaml
kubectl rollout status deployment/grafana -n monitoring
```

```
kubectl port-forward $(kubectl get pod -l app=grafana -o jsonpath={.items[0].metadata.name} -n monitoring) 3000 -n monitoring
```

Start Browser at localhost:3000


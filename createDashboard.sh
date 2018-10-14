#!/bin/bash
echo "deploy dashboard"
echo "================================================="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

echo "Deploy heapster to enable container cluster monitoring and performance analysis on your cluster"
echo "================================================="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml

echo "Deploy the influxdb backend for heapster to your cluster:"
echo "================================================="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml

echo "Create the heapster cluster role binding for the dashboard:"
echo "================================================="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml


echo "create the eks-admin service account"
echo "================================================="
kubectl apply -f eks-admin-service-account.yaml

echo "Apply the cluster role binding"
echo "================================================="

kubectl apply -f eks-admin-cluster-role-binding.yaml

echo "get auth token"
echo "================================================="

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

echo "Start the kubectl proxy, please ."
echo "open a browser with http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ and use the token from the last command for authentication"

kubectl proxy

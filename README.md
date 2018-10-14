# EKS Getting Started Guide Configuration

I took  that from  https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started

This is the full configuration from https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html



## Setup EKS via Terraform
1. terraform apply

terraformoutputs something like

```
config_map_aws_auth = 

apiVersion: v1
... 

kubeconfig = 

apiVersion: v1
clusters:
... 
```




copy the block after config_map_aws_auth into the file configmap.yml 

copy the block after kubeconfig into the file ~/.kube/config-aws 


I have setup my ```KUBECONFIG``` environment variable to support two config files, so that an additional file is supported

```KUBECONFIG=/home/christian/.kube/config:/home/christian/.kube/config-aws```


Use the new kubeconfig in config-aws with this command

```
kubectl config use-context aws
```

apply the configmap file
 
```
kubectl apply -f configmap.yml 
```

Check if the nodes come up 
```
kubectl get no --watch
```


## Create Kubernetes Dashboard


execute file createDashboard.sh to deploy the dashboard, heapster and the necessary influx.
The scripts start ```kubectl proxy``` and displays the url and access token to access the dashboard

```
./createDashboard.sh
```


https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html


## Create Ingress Controller


execute file createNGINXIngressController.sh to install an ingress controller in aws

this creates a new namespace ingress-nginx with a deployment of the image quay.io/kubernetes-ingress-controller/nginx-ingress-controller

```
./createNGINXIngressController.sh
```

https://kubernetes.github.io/ingress-nginx/deploy/
https://github.com/kubernetes/ingress-nginx


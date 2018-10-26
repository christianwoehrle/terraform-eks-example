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

cd ingress

execute file createNGINXIngressController.sh to install an ingress controller in aws

this creates a new namespace ingress-nginx with a deployment of the image quay.io/kubernetes-ingress-controller/nginx-ingress-controller. the ingress controller automatically creates an aws load balancer for external access

```
./createNGINXIngressController.sh
```

https://kubernetes.github.io/ingress-nginx/deploy/

https://github.com/kubernetes/ingress-nginx


## Install some services and corresponding ingresses

I`m experimenting with services and ingress, this is just some wip to see how I can deploy and access services

This is with an ingrewss for sveral services

```
kubectl apply -f echo1.yml -f echo2.yml -f ingress_echo1-2.yml 
```

And this command is for a service with a dedicated ingress resource.

```
kubectl apply -f echo3withIngress.yml 
```

Looks like everything works together.

## More than one Ingress Controller

You can have more than one ingress controllers, e.g. when you want have ingresses mapped to internal and external loadbalancers.

To do that, first create an internal load balancer with

```
kubectl apply -f internal-lb.yml
```

The trick is the annotation ``` service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0 ``` that tells aws to create an internal loadbalancer.

Then create a new Ingress Controller with
```
kubectl apply  -f nginx-controller-deployment.yml
```

The argument ``` --ingress-class=ingress-nginx-internal ``` tells the ingress controller that it should only treat ingresses that specify

``` kubernetes.io/ingress.class: "nginx-internal" ```


Now, deploy an internal ingres with
```
kubectl apply -f echo4InternalIngress.yml 

```
and you should see the external loadBalancer echo3 as well as the internal loadBalancer

```
kubectl get ingress
NAME      HOSTS     ADDRESS                                                                   PORTS     AGE
echo3     *         aa9133a67d45411e8b9e902cc5740c06-1837280603.eu-west-1.elb.amazonaws.com   80        4m
echo4     *                                                                                   80        55s
```

https://docs.giantswarm.io/guides/services-of-type-loadbalancer-and-multiple-ingress-controllers/


## Helm

INstall Helm
https://github.com/helm/helm/releases

kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
helm ls
helm install stable/mysql

##storage
EKSnsupports EBS out of the box. To create a default storage class execute

```
cd storage
kubectl apply -f storageclass.yml -f storageclass_cheap.yml
```

after that new pv's and pvc's can be create with the command
```
kubectl apply -f pvc.yml 
kubectl get pvc --watch
kubectl get pc --watch

```

and mount this pv into a new container:

```
kubectl apply -f pod.yml 
```

```
myserver: kubectl exec -it mypod bash
root@mypod:/# mount | grep /var/www/html
/dev/xvdbd on /var/www/html type ext4 (rw,relatime,debug,data=ordered)
root@mypod:/# root@mypod:/# df -h | grep /var/www/html
/dev/xvdbd      5.8G   24M  5.5G   1% /var/www/html
root@mypod:/# 

```

everything taken fro here: https://docs.giantswarm.io/guides/using-persistent-volumes-on-aws/





https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html

https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html



### efs

https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs



## helm

helm init




## filebeat, elastic

see https://github.com/elastic/beats/tree/master/deploy/kubernetes

and https://github.com/elastic/beats/blob/master/deploy/kubernetes/filebeat-kubernetes.yaml

```
cd filebeat
kubectl apply -f filebeat-kubernetes.yaml
```




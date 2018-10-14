# EKS Getting Started Guide Configuration

I took  that from  https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started

This is the full configuration from https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html

See that guide for additional information.

NOTE: This full configuration utilizes the [Terraform http provider](https://www.terraform.io/docs/providers/http/index.html) to call out to icanhazip.com to determine your local workstation external IP for easily configuring EC2 Security Group access to the Kubernetes master servers. Feel free to replace this as necessary.


## Usage


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

KUBECONFIG=/home/christian/.kube/config:/home/christian/.kube/config-aws


Use the new kubeconfig in config-aws with this command

kubectl config use-context aws

apply the configmap file
 
kubectl apply -f configmap.yml 

kubectl get no --watch

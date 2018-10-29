## ECR

in eks-cluster.tf a private docker repository for image heimdall is created (the repository is not open as with docker hub, but every image has to be specified)

The repository is displayed in the terraform output

https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-basics.html


To push an image to the repository the following steps are necessary:

```
#tag an image
sudo docker tag centos <aws_account_id>.dkr.ecr.<region>.amazonaws.com/heimdall

# get the login token
aws ecr get-login --no-include-email

#login
docker login -u AWS -p  <token>  <repo url>

#push
sudo docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/heimdall

#test if image in ecr is available in the kubernetes cluster

kubectl run sleep  --image=054263578675.dkr.ecr.eu-west-1.amazonaws.com/heimdall  -- sleep infinity 



```

 

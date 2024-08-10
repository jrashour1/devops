## open source project https://github.com/mongodb-developer/mean-stack-example
 - fix docker files and update outdated versions
 - fix incorrect paths in client docker file
 - created a script that takes backed path as build argument and genrate config file before spa build
 - ensure best practices ex. multistage build
 - created a docker registry 
 - created multi flavor docker-compose
    - with external mongodb
    - with dockerized mongodb and mounted volumes
## pipelines
- created ci pipeline for each serivce
- pipline genrated new image and push to registry
- update helm service values file
## IaaC
- provision vpc
- provision private subnet
- provision pulblic subnet
- provision intenet gateway
- provision NAT gateway
- provision EIP
- provision route table
- provision eks cluster
- provision node group
- provision auto-scaling group 
- provision secret in secretsmanger
## IaaC Cluster
- setup argocd
- setup argocd configs
- connect argocd with helm repo
- setup k8 metrics
- setup secret operator
- setup external secrets operator
- setup secret store manifest 
## IaaC Application
- provision client argocd application
- provision apis argocd application
## Helm Chart
- provision a deployment 
- provision a service (nlb)
- provision a secret


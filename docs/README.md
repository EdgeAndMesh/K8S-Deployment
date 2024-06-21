# K8S Cluster Setup

## Cloud

machines:

1. master:
  - 4 CPU cores, 4GiB RAM, 150GB
  - ip: `10.3.1.150`
  - OS: Ubuntu 20.04.6 LTS
2. worker 1
  - 4 CPU cores, 8GiB RAM, 80GB
  - ip: `10.3.1.102`
  - OS: Ubuntu 20.04.6 LTS
3. worker 2
  - 4 CPU cores, 8GiB RAM, 80GB
  - ip: `10.3.1.194`
  - OS: Ubuntu 20.04.6 LTS
4. worker 3
  - 3 CPU cores, 8GiB RAM, 80GB
  - ip: `10.3.3.137`
  - OS: Ubuntu 20.04.6 LTS

Kubernetes Version: `v1.26`

RKE Version: `v.1.4.15`

### RKE Deployment

Make sure you have already followed the tutorials in `cloud/master/README.md` for the
master machine and `cloud/workers/README.md` for every worker machine before
proceeding.

Deploy by running the following command:

```sh
rke up --config ~/rancher-cluster.yml --ignore-docker-version
```

![RKE Deployment](rancher-up-doc.gif)

#### [Test your cluster](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher#3-test-your-cluster)

```sh
aida@master:~$ kubectl get nodes
NAME         STATUS   ROLES               AGE   VERSION
10.3.1.102   Ready    worker              26m   v1.26.13
10.3.1.150   Ready    controlplane,etcd   26m   v1.26.13
10.3.1.194   Ready    worker              26m   v1.26.13
10.3.3.137   Ready    worker              26m   v1.26.13
```

#### [Check the Health of Your Cluster Pods](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher#4-check-the-health-of-your-cluster-pods)

```sh
aida@master:~$ kubectl get pods --all-namespaces
NAMESPACE       NAME                                      READY   STATUS      RESTARTS   AGE
ingress-nginx   ingress-nginx-admission-create-qzn79      0/1     Completed   0          27m
ingress-nginx   ingress-nginx-admission-patch-zl2cg       0/1     Completed   0          27m
ingress-nginx   nginx-ingress-controller-ml99r            1/1     Running     0          27m
ingress-nginx   nginx-ingress-controller-pnk92            1/1     Running     0          27m
ingress-nginx   nginx-ingress-controller-rqbh9            1/1     Running     0          27m
kube-system     calico-kube-controllers-f789c67d9-7m24g   1/1     Running     0          28m
kube-system     canal-7lf4r                               2/2     Running     0          28m
kube-system     canal-pjgv8                               2/2     Running     0          28m
kube-system     canal-qqscx                               2/2     Running     0          28m
kube-system     canal-sz4nq                               2/2     Running     0          28m
kube-system     coredns-66b64c55d4-b8hgf                  1/1     Running     0          28m
kube-system     coredns-66b64c55d4-ghqpj                  1/1     Running     0          27m
kube-system     coredns-autoscaler-5567d8c485-rzt9d       1/1     Running     0          28m
kube-system     metrics-server-7886b5f87c-spfqk           1/1     Running     0          28m
kube-system     rke-coredns-addon-deploy-job-cr5vk        0/1     Completed   0          28m
kube-system     rke-ingress-controller-deploy-job-6vq6p   0/1     Completed   0          27m
kube-system     rke-metrics-addon-deploy-job-vtp4z        0/1     Completed   0          28m
kube-system     rke-network-plugin-deploy-job-znp9f       0/1     Completed   0          28m
```

#### [Save your files](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher#5-save-your-files)

Save a copy of the following files in a secure location:
- `rancher-cluster.yml`: The RKE cluster configuration file.
- `kube_config_rancher-cluster.yml`: The Kubeconfig file for the cluster, this file contains credentials for full access to the cluster.
- `rancher-cluster.rkestate`: The Kubernetes Cluster State file, this file contains credentials for full access to the cluster.

### K8S App Deployment Example

This section will show how to deploy an example application in your K8S
cluster created by rancher.

The following example is available at Kubernetes Official Documentation where
they provide a basic application
["GuestBook"](https://v1-26.docs.kubernetes.io/docs/tutorials/stateless-application/guestbook/)

> This tutorial shows you how to build and deploy a simple (not production ready),
> multi-tier web application using Kubernetes and Docker. This example consists of
> the following components:
>
> - A single-instance Redis to store guestbook entries Multiple web frontend
> - instances
>
> Objectives
>
> - Start up a Redis leader.
> - Start up two Redis followers.
> - Start up the guestbook frontend.
> - Expose and view the Frontend Service.
> - Clean up.

**Your Kubernetes server must be at or later than version `v1.14`. To check the version, enter `kubectl version`**

### K8S Application Deployment

All yaml config files applies to the k8s cluster are under `examples/k8s/guestbook`.

#### Start Up the Redis Database

##### Creating the Redis Deployment

1. Launch a terminal window in the directory you downloaded the manifest files.
2. Apply the Redis Deployment from the `redis-leader-deployment.yaml` file:

```sh
kubectl apply -f ~/.local/src/K8S-Deployment/examples/k8s/guestbook/redis-leader-deployment.yaml
```

3. Query the list of Pods to verify that the Redis Pod is running:

```sh
    kubectl get pods
```

The response should be similar to this:

```sh
aida@master:~$ kubectl get pods
NAME                            READY   STATUS    RESTARTS   AGE
redis-leader-5596fc7b68-9fvtz   1/1     Running   0          6s
```

4. Run the following command to view the logs from the Redis leader Pod:

```sh
kubectl logs --follow=true deployment/redis-leader
```

##### Creating the Redis leader Service

1. Apply the Redis Service from the following `redis-leader-service.yaml` file:

```sh
kubectl apply -f ~/.local/src/K8S-Deployment/examples/k8s/guestbook/redis-leader-service.yaml
```

2. Query the list of Services to verify that the Redis Service is running:

```sh
kubectl get service
```

The response should be similar to this:The response should be similar to this:

```sh
aida@master:~$ kubectl get service
NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP    7d3h
redis-leader   ClusterIP   10.43.82.167   <none>        6379/TCP   5s
```

> *Note*: This manifest file creates a Service named redis-leader with a set of
> labels that match the labels previously defined, so the Service routes network
> traffic to the Redis Pod.

##### Set up Redis followers

1. Apply the Redis Deployment from the following
   `redis-follower-deployment.yaml` file:

```sh
kubectl apply -f ~/.local/src/K8S-Deployment/examples/k8s/guestbook/redis-follower-deployment.yaml
```

2. Verify that the two Redis follower replicas are running by querying the list of Pods:

```sh
kubectl get pods
```

The response should be similar to this:

```sh
aida@master:~$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
redis-follower-7b9cdf45b9-9tf69   1/1     Running   0          10s
redis-follower-7b9cdf45b9-vvtfs   1/1     Running   0          10s
redis-leader-5596fc7b68-9fvtz     1/1     Running   0          12m
```

##### Creating the Redis follower service

1. Apply the Redis Service from the following `redis-follower-service.yaml` file:

```sh
kubectl apply -f ~/.local/src/K8S-Deployment/examples/k8s/guestbook/redis-follower-service.yaml
```

2. Query the list of Services to verify that the Redis Service is running:

```sh
kubectl get service
```

The response should be similar to this:

```sh
aida@master:~$ kubectl get service
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes       ClusterIP   10.43.0.1       <none>        443/TCP    7d3h
redis-follower   ClusterIP   10.43.197.188   <none>        6379/TCP   9s
redis-leader     ClusterIP   10.43.82.167    <none>        6379/TCP   7m54s
```

> *Note*: This manifest file creates a Service named redis-follower with a set of
> labels that match the labels previously defined, so the Service routes network
> traffic to the Redis Pod.

#### Set up and Expose the Guestbook Frontend

Now that you have the Redis storage of your guestbook up and running, start the
guestbook web servers. Like the Redis followers, the frontend is deployed using
a Kubernetes Deployment.

The guestbook app uses a PHP frontend. It is configured to communicate with
either the Redis follower or leader Services, depending on whether the request
is a read or a write. The frontend exposes a JSON interface, and serves a
jQuery-Ajax-based UX.

##### Creating the Guestbook Frontend Deployment

1. Apply the frontend Deployment from the frontend-deployment.yaml file:

```sh
kubectl apply -f ~/.local/src/K8S-Deployment/examples/k8s/guestbook/frontend-deployment.yaml
```

2. Query the list of Pods to verify that the three frontend replicas are running:

```sh
kubectl get pods --selector app=guestbook --selector tier=frontend
```

The response should be similar to this:

```sh
aida@master:~$ kubectl get pods --selector app=guestbook --selector tier=frontend
NAME                        READY   STATUS    RESTARTS   AGE
frontend-7fd64c8b4c-2vldg   1/1     Running   0          22s
frontend-7fd64c8b4c-bvjct   1/1     Running   0          22s
frontend-7fd64c8b4c-fq8gs   1/1     Running   0          22s
```

##### Creating the Frontend Service

The Redis Services you applied is only accessible within the Kubernetes cluster
because the default type for a Service is ClusterIP. ClusterIP provides a single
IP address for the set of Pods the Service is pointing to. This IP address is
accessible only within the cluster.

If you want guests to be able to access your guestbook, you must configure the
frontend Service to be externally visible, so a client can request the Service
from outside the Kubernetes cluster. However a Kubernetes user can use kubectl
port-forward to access the service even though it uses a ClusterIP.

> *Note*: Some cloud providers, like Google Compute Engine or Google Kubernetes
> Engine, support external load balancers. If your cloud provider supports load
> balancers and you want to use it, uncomment type: LoadBalancer.

1. Apply the frontend Service from the frontend-service.yaml file:

```sh
kubectl apply -f ~/.local/src/K8S-Deployment/examples/k8s/guestbook/frontend-service.yaml
```

2. Query the list of Services to verify that the frontend Service is running:

```sh
kubectl get services
```

The response should be similar to this:

```sh
aida@master:~$ kubectl get services
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
frontend         ClusterIP   10.43.2.127     <none>        80/TCP     6s
kubernetes       ClusterIP   10.43.0.1       <none>        443/TCP    7d3h
redis-follower   ClusterIP   10.43.197.188   <none>        6379/TCP   13m
redis-leader     ClusterIP   10.43.82.167    <none>        6379/TCP   21m
```

##### Viewing the Frontend Service via kubectl port-forward

1. Run the following command to forward port 8080 on your local machine to port
   80 on the service.

```sh
kubectl port-forward svc/frontend 8080:80
```

The response should be similar to this:

```sh
aida@master:~$ kubectl port-forward svc/frontend 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

load the page http://localhost:8080 in your browser to view your guestbook.

If you don't have graphical access to your machine, you can either bind the
port-forward to the ip address of that machine on the network or listen in all
interfaces.

To listen on all interfaces:

```sh
kubectl port-forward --address=0.0.0.0 svc/frontend 8080:80
```

And then get your machine that is port forwarding to inside the cluster by
running the command:

```sh
aida@master:~$ ip --color=always -brief address | awk '/UP/ { print $3 }' | cut --delimiter='/' --fields=1
10.3.1.150
```

Then you are able to open the web interface for guestbook at:
http://10.3.1.150:8080

##### Viewing the Frontend Service via LoadBalancer

If you deployed the `frontend-service.yaml` manifest with type: LoadBalancer you
need to find the IP address to view your Guestbook.

To enable `type: LoadBalancer`, simply uncomment that line in the config file
located at
`~/.local/src/K8S-Deployment/examples/k8s/guestbook/frontend-service.yaml`, and
reapply the config.

1. Run the following command to get the IP address for the frontend Service.

```sh
kubectl get service frontend
```

The response should be similar to this:

```
NAME       TYPE           CLUSTER-IP      EXTERNAL-IP        PORT(S)        AGE
frontend   LoadBalancer   10.51.242.136   109.197.92.229     80:32372/TCP   1m
```

Copy the external IP address, and load the page in your browser to view your guestbook.

> *Note*: Try adding some guestbook entries by typing in a message, and clicking
> Submit. The message you typed appears in the frontend. This message indicates
> that data is successfully added to Redis through the Services you created
> earlier.

##### [Scale the Web Frontend](https://v1-26.docs.kubernetes.io/docs/tutorials/stateless-application/guestbook/#scale-the-web-frontend)

#### Cleaning up

Deleting the Deployments and Services also deletes any running Pods. Use labels to delete multiple resources with one command.

1. Run the following commands to delete all Pods, Deployments, and Services.

```sh
kubectl delete deployment --selector app=redis
kubectl delete service --selector app=redis
kubectl delete deployment frontend
kubectl delete service frontend
```

The response should look similar to this:

```sh
aida@master:~$ kubectl delete service --selector app=redis
service "redis-follower" deleted
service "redis-leader" deleted
aida@master:~$ kubectl delete deployment frontend
deployment.apps "frontend" deleted
aida@master:~$ kubectl delete service frontend
service "frontend" deleted
```

2. Query the list of Pods to verify that no Pods are running:

```sh
kubectl get pods
```

The response should look similar to this:

```
aida@master:~$ kubectl get pods
No resources found in default namespace.
```

## Edge

edge machines:

1. Edge 1
  - 4 CPU cores, 4GiB RAM, 24GB
  - ip: `10.3.3.202`
  - OS: Ubuntu 20.04.6 LTS
2. Edge 2
  - 6 CPU cores, 6GiB RAM, 24GB
  - ip: `10.3.1.27`
  - OS: Ubuntu 20.04.2 LTS

[KubeEdge](https://release-1-15.docs.kubeedge.io/docs/): `1.15`

### Dependencies

#### Cloud Dependencies

You will need to have a k8s cluster in the `cloud side`, make sure you have followed the [deployment
of a k8s cluster through rancher](#rke-deployment)

#### Edge Dependencies

For edge side, you will need to install a container runtime, in this tutorial we
will be installing [docker](cloud/master/README.md#k8s-setup).

### Installing Kubeedge

In this tutorial, we will be installing version `1.15` to be [compatible with
the kubernetes cluster
version](https://github.com/kubeedge/kubeedge#kubernetes-compatibility) chosen
in this project.

#### Installing Keadm

```sh
keadm-install.sh
```

### Setup Cloud Side (KubeEdge Master Node)

By default ports `10000` and `10002` in your cloudcore needs to be accessible
for your edge nodes.

<!-- TODO: Confirm kube-config location -->

```sh
keadm init --advertise-address=10.3.1.150 --profile version=v1.12.1 --kube-config="$KUBECONFIG"
```

```sh
aida@master:~$ keadm init --advertise-address=10.3.1.150 --profile version=v1.12.1 --kube-config="$KUBECONFIG"
Kubernetes version verification passed, KubeEdge installation will start...
CLOUDCORE started
=========CHART DETAILS=======
NAME: cloudcore
LAST DEPLOYED: Fri Jun 21 14:52:51 2024
NAMESPACE: kubeedge
STATUS: deployed
REVISION: 1
```

To verify:

```sh
kubectl get all -n kubeedge
```

```sh
aida@master:~$ kubectl get all -n kubeedge
NAME                             READY   STATUS    RESTARTS   AGE
pod/cloudcore-6d76c7f978-8z4kj   1/1     Running   0          53s

NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                                             AGE
service/cloudcore   ClusterIP   10.43.113.23   <none>        10000/TCP,10001/TCP,10002/TCP,10003/TCP,10004/TCP   53s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cloudcore   1/1     1            1           53s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/cloudcore-6d76c7f978   1         1         1       53s
```

#### keadm manifest generate

```sh
keadm manifest generate --advertise-address=10.3.1.150 --kube-config="$KUBECONFIG" > kubeedge-cloudcore.yaml
```

### Setup Edge Side (KubeEdge Worker Node)

#### Get Token From Cloud Side

```sh
keadm gettoken
```

#### Join Edge Node

```sh
keadm join --cloudcore-ipport=10.3.1.150:10000 --token=<token> --kubeedge-version=v1.12.1
```

To verify:

```sh
systemctl status edgecore
```

### Deploy demo on edge nodes

<!-- TODO: Deploy demo on edge nodes: https://release-1-15.docs.kubeedge.io/docs/setup/install-with-binary/#deploy-demo-on-edge-nodes

### Enable `kubectl logs` Feature

<!-- TODO: Enable kubectl logs Feature: https://release-1-15.docs.kubeedge.io/docs/setup/install-with-keadm#enable-kubectl-logs-feature -->

### Reset KubeEdge Master and Worker nodes

#### Master

```sh
keadm reset --kube-config="$KUBECONFIG"
```

#### Node

```sh
keadm reset
```

This will stop edgecore service without uninstalling/removing any of the
prerequisites.

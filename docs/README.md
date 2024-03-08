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

KubeEdge: `1.15`

RKE Version: `v.1.4.15`

## RKE Deployment

Make sure you have already followed the tutorials in `master/README.md` for the
master machine and `workers/README.md` for every worker machine before
proceeding.

Deploy by running the following command:

```sh
rke up --config ~/rancher-cluster.yml --ignore-docker-version
```

![RKE Deployment](rancher-up-doc.gif)

### [Test your cluster](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher#3-test-your-cluster)

```sh
aida@master:~$ kubectl get nodes
NAME         STATUS   ROLES               AGE   VERSION
10.3.1.102   Ready    worker              26m   v1.26.13
10.3.1.150   Ready    controlplane,etcd   26m   v1.26.13
10.3.1.194   Ready    worker              26m   v1.26.13
10.3.3.137   Ready    worker              26m   v1.26.13
```

### [Check the Health of Your Cluster Pods](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher#4-check-the-health-of-your-cluster-pods)

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

### [Save your files](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher#5-save-your-files)

Save a copy of the following files in a secure location:
- `rancher-cluster.yml`: The RKE cluster configuration file.
- `kube_config_rancher-cluster.yml`: The Kubeconfig file for the cluster, this file contains credentials for full access to the cluster.
- `rancher-cluster.rkestate`: The Kubernetes Cluster State file, this file contains credentials for full access to the cluster.

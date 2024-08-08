# Install/Upgrade Rancher on a Kubernetes Cluster
Make sure you have already followed the tutorial in `docs/metalLB` before proceeding.

## [Prerequisites](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#prerequisites)

- Kubernetes Cluster
- Ingress Controller
- CLI Tools

### [Kubernetes Cluster](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#kubernetes-cluster)

For help setting up a Kubernetes cluster, make sure you have already followed the tutorials in `docs/cloud/README.md`.

### [Ingress Controller](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#ingress-controller)

The Rancher UI and API are exposed through an Ingress. This means the Kubernetes cluster that you install Rancher in must contain an Ingress controller.

- **RKE, RKE2, and K3s**: These distributions include an Ingress controller by default, so no manual installation is needed.
- **Hosted Kubernetes Clusters (EKS, GKE, AKS)**: These do not include an Ingress controller by default. You need to manually deploy an Ingress controller.


**Since the distribution installed in `docs/cloud/README.md` is RKE, this step can be skipped.**


### [CLI Tools](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#cli-tools)
The following CLI tools are required for setting up the Kubernetes cluster. 

- **kubectl** - Kubernetes command-line tool. Follow the tutorial at `docs/cloud/README.md`. 
- **helm** - Package management for Kubernetes. To install it, run the following commands:
    ```sh
    $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    $ chmod 700 get_helm.sh
    $ ./get_helm.sh
    ```

## [Install the Rancher Helm Chart](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#install-the-rancher-helm-chart)
Rancher is installed using the Helm package manager for Kubernetes.

#### [1. Add the Helm Chart Repository](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#1-add-the-helm-chart-repository)

- Stable: Recommended for production environments

```sh
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
```

#### [2. Create a Namespace for Rancher](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#2-create-a-namespace-for-rancher)

```sh
kubectl create namespace cattle-system
```

#### [3.  Install cert-manager](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#4-install-cert-manager)

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --version v1.13.2
```

Once you’ve installed cert-manager, you can verify it is deployed correctly by checking the cert-manager namespace for running pods:
```sh
kubectl get pods --namespace cert-manager
```

#### [4. Install Rancher with Helm and Rancher-generated certificates](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#5-install-rancher-with-helm-and-your-chosen-certificate-option)

```sh
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.sneves.work \
  --set bootstrapPassword=admin

kubectl -n cattle-system rollout status deploy/rancher
``` 

#### [5. Verify that the Rancher server is successfully deployed](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster#6-verify-that-the-rancher-server-is-successfully-deployed)
```sh
kubectl -n cattle-system rollout status deploy/rancher

kubectl -n cattle-system get deploy rancher
```

#### 6. Expose Rancher via Loadbalancer

```sh
kubectl get svc -n cattle-system

kubectl expose deployment rancher --name=rancher-lb --port=443 --type=LoadBalancer -n cattle-system

kubectl get svc -n cattle-system

```

#### 7. Go to the Rancher GUI
In order to access the URL, port forwarding is needed:
- **Type**: Local
- **Forward Port**: 9090, for example
- **Destination Server**: What you have in `rancher-lb`:  `<EXTERNAL-IP>`:443
- **SSH Server**: aida@10.3.1.150:22

Then, in order to access it in the browser just type: `https://localhost:<Forward-Port>`


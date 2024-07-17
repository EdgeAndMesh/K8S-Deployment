# MetalLB
MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

## [Why](https://metallb.universe.tf/#why)
Kubernetes does not natively support network load balancers for bare-metal clusters, as its built-in implementations are designed to work with cloud providers like GCP, AWS, and Azure. This limitation causes LoadBalancer services to remain in a "pending" state indefinitely on bare-metal clusters. Instead, bare-metal cluster operators typically use NodePort and externalIPs, both of which have significant downsides for production use.

MetalLB addresses this issue by providing a network load balancer implementation specifically for bare-metal clusters. It integrates with standard network equipment, enabling external services on bare-metal clusters to function as seamlessly as they do on cloud platforms.

## [Prerequisites](https://metallb.universe.tf/#requirements)

- A **Kubernetes** cluster, running Kubernetes 1.13.0 or later, that does not already have network load-balancing functionality. Make sure you have already followed the tutorials in `docs/README.md`.
- A **cluster network configuration** that can coexist with MetalLB.
Some IPv4 addresses for MetalLB to hand out.

## [Installation](https://metallb.universe.tf/installation/)

```sh
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
```

## [Configuration](https://metallb.universe.tf/configuration/)
MetalLB remains idle until configured. This is accomplished by creating and deploying various resources into the same namespace (metallb-system) MetalLB is deployed into.

### [Layer 2](https://metallb.universe.tf/configuration/#layer-2-configuration)
The following configuration gives MetalLB control over IPs from 192.168.1.240 to 192.168.1.250 .

<h5 a><strong><code>ipAddressPool.yaml</code></strong></h5>

```sh
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.250
```
To apply the configuration:
```sh
kubectl apply -f ipAddressPool.yaml
```

In order to advertise the IP coming from an IPAddressPool, an L2Advertisement instance must be associated to the IPAddressPool. This instance configures Layer 2 mode.

<h5 a><strong><code>layer2-mode.yaml 
</code></strong></h5>

```sh
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```
To apply the configuration:
```sh
kubectl apply -f layer2-mode.yaml
```
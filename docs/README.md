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
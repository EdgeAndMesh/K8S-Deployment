#!/bin/sh
set -xe

version=v1.29.0

curl --location --remote-name "https://dl.k8s.io/release/$version/bin/linux/amd64/kubectl"
curl --location --remote-name "https://dl.k8s.io/release/$version/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install --owner=root --group=root --mode=0755 kubectl /usr/local/bin/kubectl
kubectl version --client

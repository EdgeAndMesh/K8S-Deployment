# [Plug in CA Certificates](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/)
This task shows how administrators can configure the Istio certificate authority (CA) with a root certificate, signing certificate and key.

By default the Istio CA generates a self-signed root certificate and key and uses them to sign the workload certificates. To protect the root CA key, you should use a root CA which runs on a secure machine offline, and use the root CA to issue intermediate certificates to the Istio CAs that run in each cluster. An Istio CA can sign workload certificates using the administrator-specified certificate and key, and distribute an administrator-specified root certificate to the workloads as the root of trust.

The following graph demonstrates the recommended CA hierarchy in a mesh containing two clusters.

![alt text](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/ca-hierarchy.svg)

This task demonstrates how to generate and plug in the certificates and key for the Istio CA. These steps can be repeated to provision certificates and keys for Istio CAs running in each cluster.


## [Plug in certificates and key into the cluster](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/#plug-in-certificates-and-key-into-the-cluster)

1. In the top-level directory of the Istio installation package, create a directory to hold certificates and keys:
```sh
mkdir -p certs
cd certs
```

2. Generate the root certificate and key:
```sh
make -f ../tools/certs/Makefile.selfsigned.mk root-ca
```

This will generate the following files:

- root-cert.pem: the generated root certificate
- root-key.pem: the generated root key
- root-ca.conf: the configuration for openssl to generate the root certificate
- root-cert.csr: the generated CSR for the root certificate

3. For each cluster, generate an intermediate certificate and key for the Istio CA. The following is an example for cluster1-local:

```sh
make -f ../tools/certs/Makefile.selfsigned.mk cluster1-local-cacerts
```

This will generate the following files in a directory named cluster1:

- ca-cert.pem: the generated intermediate certificates
- ca-key.pem: the generated intermediate key
- cert-chain.pem: the generated certificate chain which is used by istiod
- root-cert.pem: the root certificate

**You can replace cluster1-local with a string of your choosing. For example, with the argument cluster2-cacerts, you can create certificates and key in a directory called cluster2.**

4. In each cluster, create a secret cacerts including all the input files ca-cert.pem, ca-key.pem, root-cert.pem and cert-chain.pem. For example, for cluster1-local:
```sh 
kubectl create namespace istio-system

kubectl create secret generic cacerts -n istio-system \
      --from-file=cluster1-local/ca-cert.pem \
      --from-file=cluster1-local/ca-key.pem \
      --from-file=cluster1-local/root-cert.pem \
      --from-file=cluster1-local/cert-chain.pem
```

5. Return to the top-level directory of the Istio installation:
```sh
cd ..
```


## [Cleanup](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/#cleanup)

- Remove the certificates, keys, and intermediate files from your local disk:

```sh
rm -rf certs
```

- Remove the secret cacerts:
```sh
kubectl delete secret cacerts -n istio-system
```
 
- Remove the namespace istio-system from the cluster:
```sh
kubectl delete ns istio-system
```

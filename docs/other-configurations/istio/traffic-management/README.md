# [Secure Gateways](https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/#generate-client-and-server-certificates-and-keys)

This task shows how to expose a secure HTTPS service using either simple or mutual TLS.

## Prerequisites
1. Setup Istio by following the instructions in the `docs/other-configurations/istio/README.md` before proceeding.

2. Install openssl
```sh
sudo apt update
sudo apt install openssl
```

## [Generate client and server certificates and keys](https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/#generate-client-and-server-certificates-and-keys)

1. Create a root certificate and private key to sign the certificates for your services:
```sh
mkdir teastore_certs1

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=root Inc./CN=root.com' -keyout teastore_certs1/root.com.key -out teastore_certs1/root.com.crt
```

2. Generate a certificate and a private key for teastore.root.com:
```sh
openssl req -out teastore_certs1/teastore.root.com.csr -newkey rsa:2048 -nodes -keyout teastore_certs1/teastore.root.com.key -subj "/CN=teastore.root.com/O=teastore organization"

openssl x509 -req -sha256 -days 365 -CA teastore_certs1/root.com.crt -CAkey teastore_certs1/root.com.key -set_serial 0 -in teastore_certs1/teastore.root.com.csr -out teastore_certs1/teastore.root.com.crt
```

3. Generate a client certificate and private key:
```sh
openssl req -out teastore_certs1/client.root.com.csr -newkey rsa:2048 -nodes -keyout teastore_certs1/client.root.com.key -subj "/CN=client.root.com/O=client organization"

openssl x509 -req -sha256 -days 365 -CA teastore_certs1/root.com.crt -CAkey teastore_certs1/root.com.key -set_serial 1 -in teastore_certs1/client.root.com.csr -out teastore_certs1/client.root.com.crt
```

**Note:** You can confirm you have all the needed files by running the following command: 
```sh
ls teastore_certs1
```

## [Configure a TLS ingress gateway](https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/#configure-a-tls-ingress-gateway-for-a-single-host)

1. Create a secret for the ingress gateway:
```sh
kubectl create -n istio-system secret tls teastore-credential \
  --key=teastore_certs1/teastore.root.com.key \
  --cert=teastore_certs1/teastore.root.com.crt
```

2. Configure the ingress gateway for Istio APIs:

Create the Gateway and Virtual Service files:
<h5 a><strong><code>tls-gateway-teastore.yaml</code></strong></h5>

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: teastore-gateway
spec:
  selector:
    istio: ingressgateway 
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: teastore-credential 
    hosts:
    - teastore.root.com
```

<h5 a><strong><code>virtualservice-teastore.yaml</code></strong></h5>

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: teastore-virtualservice
spec:
  hosts:
  - "*"
  gateways:
  - teastore-gateway
  http:
  - route:
    - destination:
        host: teastore-webui
        port:
          number: 8080
```

To apply the configurations:
```sh
kubectl apply -f tls-gateway-teastore.yaml
kubectl apply -f virtualservice-teastore-yaml
```


3. Send an HTTPS request to access the teastore service through HTTPS:
```sh
curl -v -HHost:teastore.root.com --resolve "teastore.root.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
  --cacert teastore_certs1/root.com.crt "https://teastore.root.com:$SECURE_INGRESS_PORT/status/418"
```


## [Configure a mutual TLS ingress gateway](https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/#configure-a-mutual-tls-ingress-gateway)

You can extend your gateway’s definition to support mutual TLS.

1. Change the credentials of the ingress gateway by deleting its secret and creating a new one. The server uses the CA certificate to verify its clients, and we must use the key ca.crt to hold the CA certificate.
```sh
kubectl -n istio-system delete secret teastore-credential

kubectl create -n istio-system secret generic teastore-credential \
  --from-file=tls.key=teastore_certs1/teastore.root.com.key \
  --from-file=tls.crt=teastore_certs1/teastore.root.com.crt \
  --from-file=ca.crt=teastore_certs1/root.com.crt
```

2.  Configure the ingress gateway for Istio APIs:

<h5 a><strong><code>mtls-gateway-teastore.yaml</code></strong></h5>

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: teastore-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: MUTUAL
      credentialName: teastore-credential
    hosts:
    - teastore.root.com
```


To apply the configurations:
```sh
kubectl apply -f mtls-gateway-teastore.yaml
```

3. Pass a client certificate and private key to curl and resend the request. Pass your client’s certificate with the --cert flag and your private key with the --key flag to curl:
```sh
curl -v -HHost:teastore.root.com --resolve "teastore.root.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
  --cacert teastore_certs1/root.com.crt --cert teastore_certs1/client.root.com.crt --key teastore_certs1/client.root.com.key \
  "https://teastore.root.com:$SECURE_INGRESS_PORT/status/418"
  ``` 


## [Cleanup](https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/#cleanup)

- Delete the gateway configuration and routes:

```sh
kubectl delete gateway teastore-gateway
kubectl delete virtualservice teastore-virtualservice
```

- Delete the secrets, certificates and keys:
```sh
kubectl delete -n istio-system secret teastore-credential

rm -rf ./teastore_certs1
```
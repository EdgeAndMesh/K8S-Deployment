# Istio
Make sure you have already followed the tutorials in `docs/cloud/README.md` and `docs/other-configurations/metalLB/README.md` before proceeding.

## [Download Istio](https://istio.io/latest/docs/setup/getting-started/#download)

```sh
# Download and extract the latest release automatically
curl -L https://istio.io/downloadIstio | sh -

# Move to the Istio package directory.
cd istio-1.22.3

# Add the istioctl client to your path:
export PATH=$PWD/bin:$PATH
```

**Note**: `export` just makes the variable available temporarily to the current shell and its children processes. If you want to persist it, add it to `~/.profile`.  

Make sure you have installed `docs/other-configurations/istio/certificate-management/README.md` before proceeding if you want to manage and plug in custom certificates for the Istio Certificate Authority (CA).


## [Install Istio](https://istio.io/latest/docs/setup/getting-started/#install)

For this installation, we use the default configuration profile.
```sh
istioctl install --set profile=default -y
```

Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later:
```sh
kubectl label namespace default istio-injection=enabled
```

### Deploy the application
```sh
kubectl create -f https://raw.githubusercontent.com/DescartesResearch/TeaStore/master/examples/kubernetes/teastore-ribbon.yaml
```

### Open the application to outside traffic
The Teastore application is deployed but not accessible from the outside. To make it accessible, you need to create an Istio Ingress Gateway, which maps a path to a route at the edge of your mesh.

Create the Gateway and Virtual Service files:
<h5 a><strong><code>gateway-teastore.yaml</code></strong></h5>

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
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*" 
```


<h5 a><strong><code>virtualservice-teastore.yaml</code></strong></h5>

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: teastore-webui-vs
spec:
  hosts:
  - "*" 
  gateways:
  - teastore-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: teastore-webui
        port:
          number: 8080
```

To apply the configurations:
```sh
kubectl apply -f gateway-teastore.yaml
kubectl apply -f virtualservice-teastore-yaml
```


### [Determining the ingress IP and ports](https://istio.io/latest/docs/setup/getting-started/#determining-the-ingress-ip-and-ports)

Set the ingress IP and ports:

```sh
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
```

**Note**: `export` just makes the variable available temporarily to the current shell and its children processes. If you want to persist it, add it to `nano ~/.profile`.  

Ensure an IP address and port were successfully assigned to the environment variable:
```sh
echo "$GATEWAY_URL"
```


## [View the dashboard](https://istio.io/latest/docs/setup/getting-started/#dashboard)

Install Kiali and the other addons and wait for them to be deployed.
```sh
cd istio-1.22.3

kubectl apply -f samples/addons

kubectl rollout status deployment/kiali -n istio-system
```


Access the Kiali dashboard.
```sh
istioctl dashboard kiali
```

In order to access the URL, port forwarding is needed:
- **Type**: Local
- **Forward Port**: 20001, for example
- **Destination Server**: 127.0.0.1:20001
- **SSH Server**: aida@10.3.1.150:22

Then, in order to access it in the browser just type: `https://localhost:<Forward-Port>`


## [Uninstall](https://istio.io/latest/docs/setup/getting-started/#uninstall)

- To delete the Teastore application and its configuration:
```sh
kubectl delete pods,deployments,services -l app=teastore
```

- The Istio uninstall deletes the RBAC permissions and all resources hierarchically under the istio-system namespace. 
```sh
kubectl delete -f samples/addons
istioctl uninstall -y --purge
```

- The istio-system namespace is not removed by default. If no longer needed, use the following command to remove it:
```sh
kubectl delete namespace istio-system
```

- The label to instruct Istio to automatically inject Envoy sidecar proxies is not removed by default. If no longer needed, use the following command to remove it:
```sh
kubectl label namespace default istio-injection-
```
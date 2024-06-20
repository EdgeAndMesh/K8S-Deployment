# Worker Setup

## Environment Setup

### Update and Software Installation

#### Recommended

```sh
sudo apt update
sudo apt upgrade -y
sudo apt install -y htop vim bash tmux git
```

#### Optional

```sh
sudo apt install bat tree ncdu
```

### Install dotfiles

Clone this repo:

```sh
git clone git@github.com:EdgeAndMesh/K8S-Deployment.git ~/.local/src/K8S-Deployment
~/.local/src/K8S-Deployment/dotfiles/install.sh worker
```

After successful installation of dotfiles, recommended to source `~/.profile`

```sh
source ~/.profile
```

### Install scripts

```sh
~/.local/src/K8S-Deployment/scripts/install.sh cloud worker
source ~/.profile
```

**Environment Setup Complete...**

## K8S Setup

### Installing Container Runtime (Docker)

[Installing on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

```sh
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Or single command

```sh
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done && sudo apt-get update && sudo apt-get install -y ca-certificates curl && sudo install -m 0755 -d /etc/apt/keyrings && sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && sudo chmod a+r /etc/apt/keyrings/docker.asc && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### Adding user to docker group

You can add the user to the docker group to avoid needing root privileges to run
docker.

```sh
sudo usermod --append --groups docker aida
```

You can check if your user was added to the docker group by running the command:

```sh
aida@worker01:~$ grep docker /etc/group
docker:x:998:aida
```

Then after rebooting, your user will have permissions to perform docker commands


You can check if docker is installed successfully by running the following
command

```sh
sudo docker run hello-world
```

#### [Forwarding IPv4 and letting iptables see bridged traffic](https://v1-26.docs.kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic)

Better to copy command by command

```sh
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

You can verify by:

```sh
lsmod | grep br_netfilter
lsmod | grep overlay
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

#### Installing [Container Runtime Interface (cri-dockerd)](https://github.com/Mirantis/cri-dockerd)

Install by downloading the pre-built binaries from the [release page](https://github.com/Mirantis/cri-dockerd/releases)

You can run the script found in `scripts/all/cri-dockerd-install.sh`

```sh
cri-dockerd-install.sh
```

### [K8S Worker Requirements Setup](https://v1-26.docs.kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

- A compatible Linux host. The Kubernetes project provides generic instructions
  for Linux distributions based on Debian and Red Hat, and those distributions
  without a package manager.
- 2 GB or more of RAM per machine (any less will leave little room for your
  apps).
- 2 CPUs or more.
- Full network connectivity between all machines in the cluster (public or
  private network is fine).
- Unique hostname, MAC address, and product_uuid for every node. See here for
  more details.
- Certain ports are open on your machines. See here for more details.
- Swap configuration. The default behavior of a kubelet was to fail to start if
  swap memory was detected on a node. Swap has been supported since v1.22. And
  since v1.28, Swap is supported for cgroup v2 only; the NodeSwap feature gate
  of the kubelet is beta but disabled by default.
  - You MUST disable swap if the kubelet is not properly configured to use swap.
    For example, `sudo swapoff -a` will disable swapping temporarily. To make this
    change persistent across reboots, make sure swap is disabled in config files
    like /etc/fstab, systemd.swap, depending how it was configured on your
    system.
    ```sh
    sudo swapoff --all
    sudo sed -i 's/^[^#].*swap/#&/' /etc/fstab
    free -h | awk 'NR==1 || /Swap/'
    grep swap /etc/fstab
    ```

### Rancher Setup

#### [Requirements](https://rke.docs.rancher.com/os)

1. [Install Docker](#installing-container-runtime-(docker))
2. [Add user to docker group](#adding-user-to-docker-group)
3. [Swap should be disabled](#k8s-worker-requirements-setup)
4. Following sysctl settings must be applied
```sh
grep --quiet 'net.bridge.bridge-nf-call-iptables=1' /etc/sysctl.conf || echo 'net.bridge.bridge-nf-call-iptables=1' | sudo tee --append /etc/sysctl.conf
sudo sysctl --system
grep 'net.bridge.bridge-nf-call-iptables=1' /etc/sysctl.conf
```
5. [SSH Server Configuration](https://rke.docs.rancher.com/os#ssh-server-configuration)
```sh
sudo sed -i '0,/.*AllowTcpForwarding.*/s//AllowTcpForwarding yes/' /etc/ssh/sshd_config
grep AllowTcpForwarding /etc/ssh/sshd_config
sudo systemctl restart sshd
```
6. [SSH connection configuration](https://rke.docs.rancher.com/config-options/nodes#ssh-key-path)
Rancher when connecting to a node, it will use ssh the default key filepath is
`~/.ssh/id_rsa`

To generate a new ssh key run the following script
`scripts/worker/rke-generate-ssh-keys.sh` (the first argument provided to the
script should be of the form user@master_ip, this is because we need to copy the
ssh key to the master machine so that rancher can use ssh to setup the machines
belonging to the cluster):

```sh
rke-generate-ssh-keys.sh aida@10.3.1.150
```

After finishing all the configuration, you will need to reboot the machine. So
that the user added to the docker group takes effect.

```sh
sudo reboot
```

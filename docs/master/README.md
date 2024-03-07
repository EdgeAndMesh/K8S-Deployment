# Master Setup

## Environment Setup

### Update and Software Installation

#### Recommended

```sh
sudo apt update
sudo apt upgrade -y
sudo apt install -y htop vim bash tmux git gcc
```

#### Optional

```sh
sudo apt install bat tree ncdu
```

### Install dotfiles

Clone this repo:

```sh
git clone git@github.com:EdgeAndMesh/K8S-Deployment.git ~/.local/src/K8S-Deployment
cd ~/.local/src/K8S-Deployment/
dotfiles/install.sh master
```

After sucessful installation of dotfiles, recommended to source `~/.profile`

```sh
source ~/.profile
```

### Gif Generation with Asciinema

This section goes over how to generate gifs of the terminal output to look
pretty and well further ease of understanding the documentation

It's optional

#### Installing Nerd Fonts

Installing [Latest Git in Ubuntu](https://launchpad.net/~git-core/+archive/ubuntu/ppa)

```sh
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
sudo apt install -y git
```

[Installation script](https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#option-6-install-script) of nerd fonts

```sh
git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts
cd nerd-fonts
git sparse-checkout add patched-fonts/JetBrainsMono
git sparse-checkout add patched-fonts/FiraCode
./install.sh JetBrainsMono
./install.sh FiraCode
```

#### Installing the Rust Toolchain

Make sure you installed the dotfiles and source `~/.profile` previously
[rustup installation](https://www.rust-lang.org/tools/install)

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.profile
cargo install --git https://github.com/asciinema/asciinema
cargo install --git https://github.com/asciinema/agg
```

Then to start recording

```sh
asciinema rec demo.cast
```

Done...
Now if you want to convert to a gif you can use the `agg` program or after
installing the scripts, you can run `aggw`

```sh
aggw demo.cast demo.gif
```

### Install scripts

```sh
cd ~/.local/src/K8S-Deployment
scripts/install.sh master
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

You can add the user to the docker group to avoid needing root priviliges to run
docker.

```sh
sudo usermod --append --groups docker aida
```

You can check if your user was added to the docker group by running the command:

```sh
aida@master:~$ grep docker /etc/group
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

You can run the script found in `scripts/cri-dockerd-install.sh`

### [Installing kubeadm, kubelet and kubectl](https://v1-26.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)

#### Requirements

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
    ```

First check [requirements](https://v1-26.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin)

Requirements:

1. Check required ports:
```sh
nc 127.0.0.1 6443
```
2. [Install Container Runtime](https://v1-26.docs.kubernetes.io/docs/setup/production-environment/container-runtimes/)
3. [Configuring a cgroup driver](https://v1-26.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/).
Not necessary because, we will use rancher to setup the cluster

#### Installation

I will proceed to Install kubelet, kubeadm, kubectl via the [package manager way](https://v1-26.docs.kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo mkdir --parents /etc/apt/keyrings
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

Or single command

```sh
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && sudo mkdir --parents /etc/apt/keyrings && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl && sudo apt-mark hold kubelet kubeadm kubectl
```


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
sudo apt install bat tree
```

### Install dotfiles

Clone this repo:

```sh
git clone git@github.com:EdgeAndMesh/K8S-Deployment.git ~/.local/src/K8S-Deployment
cd ~/.local/src/K8S-Deployment/
dotfiles/install.sh worker
```

### Install scripts

```sh
cd ~/.local/src/K8S-Deployment
scripts/install.sh worker
```

**Environment Setup Complete...**

## K8S Setup

### [Install kubectl requirements](https://v1-26.docs.kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

I will proceed to Install kubectl via the [package manager way](https://v1-26.docs.kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo mkdir --parents /etc/apt/keyrings
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

Or single command

```sh
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && sudo mkdir --parents /etc/apt/keyrings && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && sudo apt-get update && sudo apt-get install -y kubectl
```

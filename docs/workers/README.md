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

Then after rebooting, your user will have permissions to perform docker commands


You can check if docker is installed successfully by running the following
command

```sh
sudo docker run hello-world
```

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
sudo apt-mark hold kubectl
```

Or single command

```sh
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && sudo mkdir --parents /etc/apt/keyrings && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && sudo apt-get update && sudo apt-get install -y kubectl
```

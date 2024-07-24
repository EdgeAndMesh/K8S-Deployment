# Edge Setup

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
~/.local/src/K8S-Deployment/dotfiles/install.sh edge worker
```

After successful installation of dotfiles, recommended to source `~/.profile`

```sh
source ~/.profile
```

### Install scripts

```sh
~/.local/src/K8S-Deployment/scripts/install.sh edge worker
source ~/.profile
```

**Environment Setup Complete...**

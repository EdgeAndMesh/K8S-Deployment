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
sudo apt install bat tree
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

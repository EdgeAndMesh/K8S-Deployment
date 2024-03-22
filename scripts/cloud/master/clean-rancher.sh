#!/bin/sh
set -e

RED='\033[0;31m'
RESET='\033[0m'

echo "${RED}Deprecated...${RESET}"
echo "${RED}Use \`rke remove\` instead${RESET}"
printf "%s " 'This script is destructive. Are you sure you want to continue?'
read -r confirmation

[ ! "$confirmation" = y ] && exit 1

echo Cleaning Rancher Docker images...
docker stop $(docker ps -a | awk '/rancher/ {print $1}') || true
docker rmi $(docker images | awk '/rancher/ {print $3}') || true

echo Backing up Kubernetes Config...
sudo mv /etc/kubernetes /etc/"kubernetes_$(date +"%Y_%m_%d").bak"

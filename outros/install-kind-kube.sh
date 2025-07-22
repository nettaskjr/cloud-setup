#!/usr/bin/env bash
# ------------------------------------------------------------------------ #
# Script Name:   install-kind-kube.sh
# Description:   install kubectl & kind apps
# Site:          https://amaurybsouza.medium.com/
# Written by:    Amaury Souza
# Maintenance:   Amaury Souza
# Requirements:  needs Docker installed
# ------------------------------------------------------------------------ #
# Usage:         
#       $ ./install-kind-kube.sh
# ------------------------------------------------------------------------ #
# Tested on:  
#       Bash 4.2.46
# ------------------------------------------------------------------------ # 
# History:        v1.0 10/03/2023, Amaury:
#                - start de program
#                - add the kubectl commands
#                v1.2 10/03/2023, Amaury:
#                - add the kind commands and checks
# ------------------------------------------------------------------------ #
# Thankfulness:
#       
#
#VARIABLES --------------------------------------------------------------- #
#
#CODE
#KUBECTL
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --short
#KIND
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
#END -------------------------------------------------------------------- #
#!/bin/sh
USERNAME=$USER
# set sudo
echo $USERNAME ALL=\(root\) NOPASSWD:ALL | sudo tee /etc/sudoers.d/$USERNAME
sudo chmod 0440 /etc/sudoers.d/$USERNAME

# install golang
sudo snap install go  --classic

# get asset
\mv -f .bashrc .bashrc.org
\mv -f .gitconfig .gitconfig.org
wget https://raw.githubusercontent.com/tsubasaxZZZ/template-devcontainer/master/.bashrc
wget https://raw.githubusercontent.com/tsubasaxZZZ/template-devcontainer/master/.gitconfig

# install nodejs
NODE_VERSION="lts/*"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
    && . /home/$USERNAME/.nvm/nvm.sh && nvm install ${NODE_VERSION}

# kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Azure Functions
curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update && \
    sudo apt-get install -y azure-functions-core-tools-4

# terraform
sudo apt-get install -y software-properties-common && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
    sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    sudo apt-get update && \
    sudo apt-get install -y terraform

# Python3
sudo apt-get install -y python3 \
    python3-pip \
    python3-venv \
    python3.8-dev

# Ansible
PATH=$PATH:/opt/ansible/bin
sudo pip3 install virtualenv \
    && cd /opt \
    && sudo virtualenv -p python3 ansible \
    && /bin/bash -c "source ansible/bin/activate && pip3 install ansible && pip3 install 'pywinrm>=0.2.2' && deactivate" \
    && ansible-galaxy collection install azure.azcollection
cd

# Install packer
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y packer

# Download and install AzCopy SCD of linux-x64
curl -sSL https://aka.ms/downloadazcopy-v10-linux -o azcopy-netcore_linux_x64.tar.gz \
    && mkdir azcopy \
    && tar xf azcopy-netcore_linux_x64.tar.gz -C azcopy --strip-components 1 \
    && sudo mv azcopy/azcopy /usr/local/bin/azcopy \
    && sudo chmod a+x /usr/local/bin/azcopy \
    && rm -f azcopy-netcore_linux_x64.tar.gz && rm -rf azcopy

# krew plugin
curl -fsSL -o /tmp/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz" \
    && tar zxvf /tmp/krew.tar.gz -C /tmp \
    && sudo mv /tmp/krew-linux_amd64 /usr/local/bin/krew


# Install Java environment
sudo apt-get install -y zip unzip
curl -s "https://get.sdkman.io" | bash \
    && source "$HOME/.sdkman/bin/sdkman-init.sh" \
    && mkdir -p ~/.sdkman/etc/ \
    && echo "sdkman_curl_connect_timeout=120" >> ~/.sdkman/etc/config \
    && echo "sdkman_curl_max_time=0" >> ~/.sdkman/etc/config \
    && sdk install java 11.0.11.9.1-ms \
    && sdk install gradle \
    && sdk install maven
# Install krew plugin
krew install krew \
    && krew install ns \
    && krew install ctx

sudo apt-get install -y \
    file \
    vim \
    bash-completion

wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -O /home/${USERNAME}/.git-completion.bash && \
    wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O /home/${USERNAME}/.git-prompt.sh

sudo apt-get install -y peco
mkdir .kube \
    && kubectl completion bash > ~/.kube/completion.bash.inc \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    &&  ~/.fzf/install --completion --key-bindings --update-rc \
    && go install github.com/x-motemen/ghq@latest

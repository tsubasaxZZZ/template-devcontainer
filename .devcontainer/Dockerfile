# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.155.1/containers/go/.devcontainer/base.Dockerfile
FROM golang:latest as golang


FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-20.04
SHELL [ "/bin/bash", "-c" ]

COPY [".", ".bashrc", ".gitconfig", ".vscode", "/app/"]

ARG USERNAME=tsunomur
ARG USER_UID=1100
ARG USER_GID=$USER_UID

RUN sh -c 'echo "[interop]\nappendWindowsPath = false" > /etc/wsl.conf'

RUN sed -i.org -e "s/\/\/archive\.ubuntu\.com/\/\/jp\.archive\.ubuntu\.com/g" /etc/apt/sources.list
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash -d /home/$USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
RUN chown -R ${USERNAME}:${USERNAME} /app

# Install golang
COPY --from=golang /usr/local/go /usr/local/go/

# Install Node.js
USER $USERNAME
ARG NODE_VERSION="lts/*"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
    && . /home/$USERNAME/.nvm/nvm.sh && nvm install ${NODE_VERSION}
USER root

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Azure Functions
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
RUN mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
RUN apt-get update && \
    apt-get install azure-functions-core-tools-3

# terraform
RUN apt-get install -y software-properties-common && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && \
    apt-get install terraform

# Python3
RUN apt-get install -y python3 \
    python3-pip \
    python3-venv \ 
    python3.8-dev

# Ansible
ENV PATH $PATH:/opt/ansible/bin
RUN pip3 install virtualenv \
    && cd /opt \
    && virtualenv -p python3 ansible \
    && /bin/bash -c "source ansible/bin/activate && pip3 install ansible && pip3 install pywinrm>=0.2.2 && deactivate" \
    && ansible-galaxy collection install azure.azcollection

# Download and Install the latest packer (AMD64)
RUN PACKER_VERSION=$(curl -sSL https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r -M ".current_version") \
    && wget -nv -O packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && wget -nv -O packer.sha256 https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS \
    && wget -nv -O packer.sha256.sig https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS.sig \
    && curl -s https://keybase.io/hashicorp/pgp_keys.asc | gpg --import \
    && gpg --verify packer.sha256.sig packer.sha256 \
    && echo $(grep -Po "[[:xdigit:]]{64}(?=\s+packer_${PACKER_VERSION}_linux_amd64.zip)" packer.sha256) packer.zip | sha256sum -c \
    && unzip packer.zip \
    && mv packer /usr/local/bin \
    && chmod a+x /usr/local/bin/packer \
    && rm -f packer packer.zip packer.sha256 packer.sha256.sig \
    && unset PACKER_VERSION

# Download and install AzCopy SCD of linux-x64
RUN curl -sSL https://aka.ms/downloadazcopy-v10-linux -o azcopy-netcore_linux_x64.tar.gz \
    && mkdir azcopy \
    && tar xf azcopy-netcore_linux_x64.tar.gz -C azcopy --strip-components 1 \
    && mv azcopy/azcopy /usr/local/bin/azcopy \
    && chmod a+x /usr/local/bin/azcopy \
    && rm -f azcopy-netcore_linux_x64.tar.gz && rm -rf azcopy

# krew plugin
RUN curl -fsSL -o /tmp/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" \
    && tar zxvf /tmp/krew.tar.gz -C /tmp \
    && mv /tmp/krew-linux_amd64 /usr/local/bin/krew

USER $USERNAME
# Install Java environment
RUN curl -s "https://get.sdkman.io" | bash \
    && source "$HOME/.sdkman/bin/sdkman-init.sh" \
    && mkdir -p ~/.sdkman/etc/ \
    && echo "sdkman_curl_connect_timeout=120" >> ~/.sdkman/etc/config \
    && echo "sdkman_curl_max_time=0" >> ~/.sdkman/etc/config \
    && sdk install java 11.0.11.9.1-ms \
    && sdk install gradle \
    && sdk install maven
# Install krew plugin
RUN krew install krew \
    && krew install ns \
    && krew install ctx
USER root

#ARG MAVEN_VERSION=3.8.1
#ARG MAVEN_BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
#ARG GRADLE_VERSION=7.0.2
#RUN apt install -y default-jdk \
#&& mkdir -p /opt/maven \
#&& curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
#&& tar -xzf /tmp/apache-maven.tar.gz -C /opt/maven --strip-components=1 \
#&& rm -f /tmp/apache-maven.tar.gz \
#&& mkdir /opt/gradle

# Other
RUN apt-get install -y \
    file \
    vim
RUN wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -O /home/${USERNAME}/.git-completion.bash && \
    wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O /home/${USERNAME}/.git-prompt.sh

RUN ln -sf /app/.bashrc /home/${USERNAME}/.bashrc \
    && ln -sf /app/.gitconfig /home/${USERNAME}/.gitconfig

#RUN apt-get install -y software-properties-common
#RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
#    apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
#    apt-get install -y terraform


# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment the next line to use go get to install anything else you need
RUN apt-get install peco
# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

USER $USERNAME
WORKDIR /home/${USERNAME}
RUN mkdir .kube \
    && kubectl completion bash > ~/.kube/completion.bash.inc \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    &&  ~/.fzf/install --completion --key-bindings --update-rc \
    && /usr/local/go/bin/go get github.com/x-motemen/ghq

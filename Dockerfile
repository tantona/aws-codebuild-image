FROM golang AS build-env
ADD ./addons /go/src/github.com/tantona
WORKDIR /go/src/github.com/tantona
RUN go install ./...

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3-pip \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

COPY --from=build-env /go/bin/send-slack-notification /usr/local/bin

# install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu

# install docker compose
RUN curl -sL "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# install aws-cli
RUN pip3 install awscli --upgrade

# install kubectl
RUN curl -sL https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod 0755 /usr/local/bin/kubectl

# install eksctl
RUN curl -sL "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /usr/local/bin

# install helm
RUN curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash \
    && curl -sL "https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator" -o /usr/local/bin/aws-iam-authenticator \
    && chmod 0755 /usr/local/bin/aws-iam-authenticator

# nvm environment variables
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 8.8.1

# install nvm
# https://github.com/creationix/nvm#install-script
RUN mkdir -p /root/.nvm && curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# install node and npm
RUN . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends yarn \
    && apt-get -y autoclean

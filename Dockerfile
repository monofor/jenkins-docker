FROM jenkins/jenkins:latest
# if we want to install via apt
USER root
RUN apt-get update && apt-get install -y --no-install-recommends git
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1

# Install .NET CLI dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libc6 \
    libcurl3 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu57 \
    liblttng-ust0 \
    libssl1.0.2 \
    libstdc++6 \
    libunwind8 \
    libuuid1 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK
RUN echo "Installing dotnet SDK 2.1.805 (v2.1)"
ENV DOTNET_SDK_DOWNLOAD_URL https://download.visualstudio.microsoft.com/download/pr/e730fe40-e2ea-42e5-a5d0-f86830d75849/571e5a2f4ebf9f8117878eeaad5cb19b/dotnet-sdk-2.1.805-linux-x64.tar.gz
ENV DOTNET_SDK_DOWNLOAD_SHA ceceaf569060c313e9e1b519ad2bfda37bb11c4549689d01080bed84b8a1b64f4c8a35fce4622b2f951a7ccf574e7ea4552c076fa2ba302846d4e1c5ae5b3a0c

RUN curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && echo "$DOTNET_SDK_DOWNLOAD_SHA dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

RUN echo "Installing dotnet SDK 3.1.201 (v3.1)"
ENV DOTNET_SDK_DOWNLOAD_URL https://download.visualstudio.microsoft.com/download/pr/f65a8eb0-4537-4e69-8ff3-1a80a80d9341/cc0ca9ff8b9634f3d9780ec5915c1c66/dotnet-sdk-3.1.201-linux-x64.tar.gz
ENV DOTNET_SDK_DOWNLOAD_SHA 934bf29734776331691a4724f2174c4e9d2d1dde160f18397fd01abf0f96f2ec1bdd2874db9f0e25dce6993d527ea9c19031a0e67383fd813dcfcb9552ea0c70

RUN curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && echo "$DOTNET_SDK_DOWNLOAD_SHA dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz

# Trigger the population of the local package cache
ENV NUGET_XMLDOC_MODE skip
RUN mkdir warmup \
    && cd warmup \
    && dotnet new \
    && cd .. \
    && rm -rf warmup \
    && rm -rf /tmp/NuGetScratch


# Installing nuget package manager credential provider

ADD installcredprovider.sh /
RUN chmod +x installcredprovider.sh
RUN /installcredprovider.sh

### END .NET

# Install Node.js
ENV NODE_VERSION 12.16.1
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz
ENV NODE_DOWNLOAD_SHA 074a6129da34b768b791f39e8b74c6e4ab3349d1296f1a303ef3547a7f9cf9be

RUN curl -SL "$NODE_DOWNLOAD_URL" --output nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Install yarn
RUN npm install -g yarn

# Install Docker
RUN apt-get update && \
    apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get -y install docker-ce

# Install SonarQube Dotnet Tool
RUN dotnet tool install --tool-path /usr/share/dotnet/tools dotnet-sonarscanner
ENV PATH="/usr/share/dotnet/tools:$PATH"
RUN chmod +x /usr/share/dotnet/tools/dotnet-sonarscanner

RUN chown -R jenkins:docker /var/jenkins_home
RUN chown -R jenkins:docker /usr/share/dotnet/

RUN sudo usermod -aG docker jenkins

# install Terraform

RUN wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip \
    && unzip terraform_0.11.13_linux_amd64.zip \
    && mv terraform /usr/bin \
    && rm terraform_0.11.13_linux_amd64.zip

# drop back to the regular jenkins user - good practice
USER jenkins
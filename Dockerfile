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
RUN echo "Installing dotnet SDK 2.2.402 (v2.2.7)"
ENV DOTNET_SDK_DOWNLOAD_URL https://download.visualstudio.microsoft.com/download/pr/46411df1-f625-45c8-b5e7-08ab736d3daa/0fbc446088b471b0a483f42eb3cbf7a2/dotnet-sdk-2.2.402-linux-x64.tar.gz
ENV DOTNET_SDK_DOWNLOAD_SHA 81937DE0874EE837E3B42E36D1CF9E04BD9DEFF6BA60D0162AE7CA9336A78F733E624136D27F559728DF3F681A72A669869BF91D02DB47C5331398C0CFDA9B44

RUN curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && echo "$DOTNET_SDK_DOWNLOAD_SHA dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

RUN echo "Installing dotnet SDK 3.1.100 (v3.1.0)"
ENV DOTNET_SDK_DOWNLOAD_URL https://download.visualstudio.microsoft.com/download/pr/d731f991-8e68-4c7c-8ea0-fad5605b077a/49497b5420eecbd905158d86d738af64/dotnet-sdk-3.1.100-linux-x64.tar.gz
ENV DOTNET_SDK_DOWNLOAD_SHA 5217ae1441089a71103694be8dd5bb3437680f00e263ad28317665d819a92338a27466e7d7a2b1f6b74367dd314128db345fa8fff6e90d0c966dea7a9a43bd21

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
ENV NODE_VERSION 12.13.1
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
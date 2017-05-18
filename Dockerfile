FROM ubuntu:xenial

ARG dotnet_tools_version=1.0.1
ARG docker_version=17.03.0~ce-0~ubuntu-xenial

# Install packages
RUN echo "deb [arch=amd64] http://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list \
 && apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    git \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    locales \
    curl \
    dnsutils \
    ftp \
    iproute2 \
    iputils-ping \
    openssh-client \
    sudo \
    telnet \
    time \
    unzip \
    wget \
    zip \
    dotnet-dev-${dotnet_tools_version} \
    nuget \ 
    build-essential \
 && rm -rf /var/lib/apt/lists/* && apt-get clean

# Setup locale
RUN locale-gen en_US.UTF-8 \
  && echo "LANG=en_US.UTF-8" >> /etc/default/locale

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install docker-ce=${docker_version}  -y \
  && rm -rf /var/lib/apt/lists/* && apt-get clean

# Install stable Node.js and related build tools
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
 && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/* && apt-get clean

 # Install MS SQL command line tools
 RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
  && apt-get update -y \
  && ACCEPT_EULA=Y apt-get install mssql-tools unixodbc-dev -y \
  && rm -rf /var/lib/apt/lists/* && apt-get clean

# Diable telemetry
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# Forces first run which downloads and unpacks some stuff.
RUN /usr/bin/dotnet msbuild /version

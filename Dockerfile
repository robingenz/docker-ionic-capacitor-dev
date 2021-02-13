FROM ubuntu:18.04

LABEL MAINTAINER="Robin Genz <mail@robingenz.dev>"

ARG JAVA_VERSION=8
ARG NODEJS_VERSION=12
ARG ANDROID_SDK_VERSION=6200805
ARG ANDROID_BUILD_TOOLS_VERSION=28.0.3
ARG ANDROID_PLATFORMS_VERSION=29
ARG GRADLE_VERSION=5.6.4
ARG RUBY_VERSION=2.7.1
ARG CHROME_VERSION=81.0.4044.138-1

ARG USERNAME=vscode
ARG USER_UID=1001
ARG USER_GID=$USER_UID
ARG HOME=/home/${USERNAME}
ARG WORKDIR=$HOME

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

WORKDIR /tmp

SHELL ["/bin/bash", "-l", "-c"] 

RUN apt-get update -q

# General packages
RUN apt-get install -qy \
    apt-utils \
    locales \
    gnupg2 \
    build-essential \
    curl \
    usbutils \
    git \
    unzip \
    p7zip p7zip-full \
    python \
    openjdk-${JAVA_VERSION}-jre \
    openjdk-${JAVA_VERSION}-jdk

# Set locale
RUN locale-gen en_US.UTF-8 && update-locale

# Add user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --create-home --uid $USER_UID --gid $USER_GID -m $USERNAME

# [Optional] Add sudo support for the non-root user
RUN apt-get install -qy sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Ruby
RUN mkdir ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    && curl -sSL https://get.rvm.io | bash \
    && source /usr/local/rvm/scripts/rvm \
    && rvm install ruby-${RUBY_VERSION} \
    && rvm --default use ruby-${RUBY_VERSION}
ENV GEM_HOME=${HOME}/.ruby
ENV PATH=$PATH:${HOME}/.ruby/bin

# Install Gradle
ENV GRADLE_HOME=/opt/gradle
RUN mkdir $GRADLE_HOME \
    && curl -sL https://downloads.gradle-dn.com/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle-${GRADLE_VERSION}-bin.zip \
    && unzip -d $GRADLE_HOME gradle-${GRADLE_VERSION}-bin.zip
ENV PATH=$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin

# Install Android SDK tools
ENV ANDROID_HOME=/opt/android-sdk
RUN curl -sL https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -o commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
    && unzip commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
    && mkdir $ANDROID_HOME && mv tools $ANDROID_HOME \
    && yes | $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses \
    && $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platforms;android-${ANDROID_PLATFORMS_VERSION}"
ENV PATH=$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash - \
    && apt-get update -q && apt-get install -qy nodejs
ENV NPM_CONFIG_PREFIX=${HOME}/.npm-global
ENV PATH=$PATH:${HOME}/.npm-global/bin

# Install Bundler
RUN gem install bundler

# Install Chrome
RUN curl -sL https://dl-ssl.google.com/linux/linux_signing_key.pub -o chrome_linux_signing_key.pub \
    && apt-key add chrome_linux_signing_key.pub \
    && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -q && apt-get install -qy google-chrome-stable=${CHROME_VERSION}

# Copy adbkey
RUN mkdir -p -m 0750 /root/.android
COPY adbkey/adbkey /root/.android/
COPY adbkey/adbkey.pub /root/.android/

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

WORKDIR $WORKDIR

USER $USERNAME

ENTRYPOINT ["/bin/bash", "-l", "-c"]

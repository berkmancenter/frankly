FROM ubuntu:20.04

WORKDIR /flutter
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install curl xz-utils git unzip sudo openjdk-13-jre \
    nodejs npm
RUN curl -sL https://firebase.tools | bash
RUN curl https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.6-stable.tar.xz -O
RUN tar -xf flutter_linux_1.22.6-stable.tar.xz
ENV PATH="$PATH:/flutter/flutter/bin"

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y x11vnc xvfb fluxbox wmctrl wget gnupg2
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install google-chrome-stable

RUN flutter channel beta && flutter upgrade && flutter config --enable-web
RUN touch /root/.config

WORKDIR /junto
RUN git clone https://gitlab.com/dannnnthemannnn/programmable-video.git && cd programmable-video && \
    git checkout 55a0bd98b75731f58458621258f1afddcfd20d22

WORKDIR /junto/junto/client
CMD ["/bin/bash"]

FROM ubuntu:22.04

LABEL maintainer="Reinhard Pointner <rednoah@filebot.net>"


ENV FILEBOT_VERSION 4.9.6
ENV FILEBOT_RELEASE 2022-05-22

RUN set -eux \
 ## ** install dependencies
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jre-headless libjna-java mediainfo libchromaprint-tools unrar p7zip-full p7zip-rar xz-utils ffmpeg mkvtoolnix atomicparsley sudo gnupg curl file inotify-tools \
 && rm -rvf /var/lib/apt/lists/* \
 ## ** FIX libjna-java (see https://bugs.launchpad.net/ubuntu/+source/libjna-java/+bug/2000863)
 && ln -s /usr/lib/*-linux-gnu*/jni /usr/lib/jni

RUN set -eux \
 ## ** install filebot
 && curl -fsSL "https://get.filebot.net/filebot/FileBot_4.9.6/FileBot_4.9.6_universal.deb" --output "filebot.deb"  \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt install -y ./filebot.deb \
 ## ** apply custom application configuration
 && sed -i 's/APP_DATA=.*/APP_DATA="$HOME"/g; s/-Dapplication.deployment=deb/-Dapplication.deployment=docker/g' /usr/bin/filebot


# install custom launcher scripts
COPY generic /


ENV HOME /data
ENV LANG C.UTF-8

ENV PUID 1000
ENV PGID 1000
ENV PUSER filebot
ENV PGROUP filebot


ENTRYPOINT ["/opt/bin/run-as-user", "/opt/bin/run", "/usr/bin/filebot"]

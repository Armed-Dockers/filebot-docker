FROM azul/zulu-openjdk-alpine:20-latest

LABEL maintainer="hackmonker lol"


ENV FILEBOT_VERSION 4.9.6
ENV FILEBOT_URL https://get.filebot.net/filebot/FileBot_$FILEBOT_VERSION/FileBot_$FILEBOT_VERSION-portable.tar.xz

ENV FILEBOT_HOME /opt/filebot
ENV LICENSE 



RUN apk add --no-cache mediainfo chromaprint p7zip
RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/v3.14/main/ unrar

RUN set -eux \
 ## * fetch portable package
 && wget -O /tmp/filebot.tar.xz "$FILEBOT_URL" \
 ## * install application files
 && mkdir -p "$FILEBOT_HOME" \
 && tar --extract --file /tmp/filebot.tar.xz --directory "$FILEBOT_HOME" --verbose \
 && rm -v /tmp/filebot.tar.xz \
 ## * delete incompatible native binaries
 && find /opt/filebot/lib -type f -not -name libjnidispatch.so -delete \
 ## * link /opt/filebot/data -> /data to persist application data files to the persistent data volume
 && ln -s /data /opt/filebot/data

COPY cracked-jar/filebot.jar /opt/filebot/

#crack filebot
# RUN wget -O /opt/filebot/filebot.jar "https://hackmonker:IAMHERO1234@webdav.shuvsp.me/Toshiba/filebot.jar" \
RUN mv -f /opt/filebot/filebot.jar /opt/filebot/jar/ \
 && echo "$LICENSE" > /opt/filebot/license.psm \
 && /opt/filebot/filebot.sh --license /opt/filebot/license.psm


ENV HOME /data
ENV LANG C.UTF-8
ENV FILEBOT_OPTS "-Dapplication.deployment=docker -Dnet.filebot.archive.extractor=ShellExecutables -Duser.home=$HOME"


ENTRYPOINT ["/opt/filebot/filebot.sh"]
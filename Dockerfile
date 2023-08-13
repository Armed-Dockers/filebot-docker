FROM azul/zulu-openjdk-alpine:20-latest

LABEL maintainer="hackmonker lol"


ENV FILEBOT_VERSION 4.9.6
ENV FILEBOT_URL https://get.filebot.net/filebot/FileBot_$FILEBOT_VERSION/FileBot_$FILEBOT_VERSION-portable.tar.xz

ENV FILEBOT_HOME /opt/filebot
ENV LICENSE "-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Product: FileBot Elite Edition
Order: 1337
Email: DVT@SCENE.INC
Credits: DVT
-----BEGIN PGP SIGNATURE-----
Version: BCPG v1.69

iQErBAEDCgAVBQJk2SJvDhxkdnRAc2NlbmUuaW5jAAoJEPFozA3utoaXjx0H+QFX
yr77xanQlzkVD90Xc70UWMjBxt48YwG8ADP+fswrM7umhSrScYnpvUijWQSa9gOF
pMmVfkSq4qCkAQ2/usnHCrf7hXs2jqaiARFqQT4eik+Rmf3f7ujllx8MFr38sK3T
8SwrVseDf8hDnK8dr1KiaSOMrZ18Q4arwat2KMzNEgVMC/NILQlRWbiJC3WCScIw
SUEJfe8xHFve3rOWQsRKh3QDYNQBcaiI4NrrltzTcgxOeEan4Vemma035+sSq7CJ
9d9eWQQnDgxw9YrzWwhLvatuNwqd4p3kHdKbihzZn68SIw4WXAY8mPidOTZETZ6e
rWlyjNGX6ts5RZc6N68=
=N2GF
-----END PGP SIGNATURE-----"




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
 && echo $LICENSE > /opt/filebot/license.psm \
 && /opt/filebot/filebot.sh --license /opt/filebot/license.psm


ENV HOME /data
ENV LANG C.UTF-8
ENV FILEBOT_OPTS "-Dapplication.deployment=docker -Dnet.filebot.archive.extractor=ShellExecutables -Duser.home=$HOME"


ENTRYPOINT ["/opt/filebot/filebot.sh"]
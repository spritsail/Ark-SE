FROM debian:buster-slim

ARG ARK_TOOLS_VER=1.6.53

# Var for first config
ENV SESSIONNAME="Ark Docker" \
    SERVERMAP="TheIsland" \
    SERVERPASSWORD="" \
    ADMINPASSWORD="adminpassword" \
    MAX_PLAYERS=70 \
    UPDATEONSTART=1 \
    BACKUPONSTART=1 \
    SERVERPORT=27015 \
    STEAMPORT=7778 \
    BACKUPONSTOP=1 \
    WARNONSTOP=1 \
    ARK_UID=1000 \
    ARK_GID=1000 \
    TZ=UTC

LABEL maintainer="Spritsail <ark@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="Ark: Survival Evolved" \
      org.label-schema.url="https://github.com/beetbox/ark-se" \
      org.label-schema.description="Game server & management tools to let you run away from Rex easier." \
      org.label-schema.version="v1.6" \
      io.spritsail.version.ark-server-tools=${ARK_TOOLS_VER}

## Install dependencies

RUN DEBIAN_FRONTEND=noninteractive apt update \
 && apt install -y --no-install-recommends perl-modules curl lsof libc6-i386 lib32gcc1 bzip2 unzip cron ca-certificates\
 && useradd -u $ARK_UID -s /bin/bash -U steam

# Copy & rights to folders
COPY *.sh crontab arkmanager-user.cfg /home/steam/
COPY arkmanager-user.cfg /home/steam/arkmanager.cfg


RUN chmod 755 /home/steam/*.sh \
 ## Always get the latest version of ark-server-tools
 && curl -L https://github.com/FezVrasta/ark-server-tools/archive/v${ARK_TOOLS_VER}.tar.gz | tar xz --strip-components=1 -C /tmp ark-server-tools-${ARK_TOOLS_VER}/tools \
 && cd /tmp/tools \
 && bash /tmp/tools/install.sh steam --bindir=/usr/bin \
 && (crontab -l 2>/dev/null; echo "* 3 * * Mon yes | arkmanager upgrade-tools >> /ark/log/arkmanager-upgrade.log 2>&1") | crontab - \
 && mkdir /ark \
 && chown steam /ark && chmod 755 /ark \
 && mkdir /home/steam/steamcmd \
 && cd /home/steam/steamcmd \
 && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - \
 && rm -r /tmp/tools \
 && apt clean

# Define default config file in /etc/arkmanager
COPY arkmanager-system.cfg /etc/arkmanager/arkmanager.cfg
# Define default config file in /etc/arkmanager
COPY instance.cfg /etc/arkmanager/instances/main.cfg

EXPOSE ${STEAMPORT} 32330 ${SERVERPORT} ${STEAMPORT}/udp ${SERVERPORT}/udp

VOLUME /ark

WORKDIR /ark

ENTRYPOINT ["/home/steam/user.sh"]

FROM ubuntu:14.04

MAINTAINER TuRzAm

# Var for first config
# Server Name
ENV SESSIONNAME "Ark Docker"
# Map name
ENV SERVERMAP "TheIsland"
# Server password
ENV SERVERPASSWORD ""
# Admin password
ENV ADMINPASSWORD "adminpassword"
# Nb Players
ENV NBPLAYERS 70
# If the server is updating when start with docker start
ENV UPDATEONSTART 1
# if the server is backup when start with docker start
ENV BACKUPONSTART 1
# Nb minute between auto update (warm) (-1 : no auto update)
ENV AUTOUPDATE -1
# Nb minute between auto backup (-1 : no auto backup)
ENV AUTOBACKUP -1


# Install dependencies 
RUN apt-get update &&\ 
    apt-get install -y curl lib32gcc1 lsof git 


# Run commands as the steam user
RUN adduser \ 
	--disabled-login \ 
	--shell /bin/bash \ 
	--gecos "" \ 
	steam

# Copy & rights to folders
COPY run.sh /home/steam/run.sh
COPY arkmanager.cfg /home/steam/arkmanager.cfg

RUN chmod 777 /home/steam/run.sh
RUN mkdir  /ark


# We use the git method, because api github has a limit ;)
RUN  git clone https://github.com/FezVrasta/ark-server-tools.git /home/steam/ark-server-tools
# Install 
WORKDIR /home/steam/ark-server-tools/tools
RUN chmod +x install.sh 
RUN ./install.sh steam 

# Define default config file in /ark
RUN echo 'source /ark/arkmanager.cfg' > /etc/arkmanager/arkmanager.cfg


RUN chown steam -R /ark && chmod 755 -R /ark



USER steam 

# download steamcmd
RUN mkdir /home/steam/steamcmd &&\ 
	cd /home/steam/steamcmd &&\ 
	curl http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -vxz 


# First run is on anonymous to download the app
RUN /home/steam/steamcmd/steamcmd.sh +login anonymous +quit



EXPOSE 7778 27016 32330

VOLUME  /ark 

# Update game launch the game.
ENTRYPOINT ["/home/steam/run.sh"]
FROM amd64/debian:latest
MAINTAINER Bram Hoven <info@bramhoven.nl>

# Install packets: 
RUN apt-get update && apt-get install -y apt-utils libsdl-image1.2 libsdl-ttf2.0-0 libgtk2.0-0 libglu1-mesa libopenal1 libncurses5 libncursesw5 zlib1g lbzip2 tmux openssh-server sudo locales

ENV DF_VERSION 47_05

ADD http://www.bay12games.com/dwarves/df_${DF_VERSION}_linux.tar.bz2 /
RUN tar xf /df_${DF_VERSION}_linux.tar.bz2
RUN rm /df_${DF_VERSION}_linux.tar.bz2

# Disabled libs, let df use system's libs
RUN mv /df_linux/libs/libstdc++.so.6 /df_linux/libs/libstdc++.so.6.bak
RUN mv /df_linux/libs/libgcc_s.so.1 /df_linux/libs/libgcc_s.so.1.bak

# configure cli mode
RUN sed -i 's/SOUND:YES/SOUND:NO/g' /df_linux/data/init/init.txt
RUN sed -i 's/PRINT_MODE:2D/PRINT_MODE:TEXT/g' /df_linux/data/init/init.txt
RUN sed -i 's/INTRO:ON/INTRO:OFF/g' /df_linux/data/init/init.txt

# disable annoying output
RUN rm -f /df_linux/gamelog.txt ; ln -sf /dev/null /df_linux/gamelog.txt
RUN rm -f /df_linux/errorlog.txt ; ln -sf /dev/null /df_linux/errorlog.txt
RUN ln -sf /dev/null /df_linux/stdout.log
RUN ln -sf /dev/stderr /df_linux/stderr.log

# create and export save dir
RUN mkdir -p /df_linux/data/save
VOLUME /df_linux/data/save

# setup locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LC_ALL en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en     

# setup ssh server for remote playing
RUN useradd -d /df_linux -s /bin/bash -g root df
RUN  echo 'df:dwarffortress' | chpasswd
RUN chown df:root -R /df_linux
RUN service ssh start

USER df
RUN touch /df_linux/.profile
RUN echo export LC_ALL=en_US.utf8 >> /df_linux/.profile
RUN echo tmux set -g status off >> /df_linux/.profile
RUN echo tmux a -t df >> /df_linux/.profile

USER root

WORKDIR /df_linux

COPY ./entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]

CMD ["/entrypoint.sh"]
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/minimal-notebook

USER $NB_USER

#Install nbgrader
RUN conda install nbgrader

RUN jupyter nbextension install --user --py nbgrader
RUN jupyter nbextension enable --user --py nbgrader
RUN jupyter serverextension enable --user --py nbgrader

ENV GOVERSION=1.12.6

USER root
# set workdir != /home/jovyan
WORKDIR /root
RUN wget https://dl.google.com/go/go$GOVERSION.linux-amd64.tar.gz && \
	tar -C /usr/local -xzf go$GOVERSION.linux-amd64.tar.gz

RUN apt-get update && apt-get install -y git libtool pkg-config build-essential autoconf automake uuid-dev libzmq3-dev



USER $NB_USER
WORKDIR /home/jovyan

ENV GOROOT=/usr/local/go
ENV GOPATH=/home/jovyan/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

RUN go get -u github.com/gopherdata/gophernotes && \
 	mkdir -p ~/.local/share/jupyter/kernels/gophernotes && \
  cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* ~/.local/share/jupyter/kernels/gophernotes
WORKDIR /home/jovyan/work
RUN conda install -c conda-forge rise
USER root
RUN apt-get install -y curl texlive-publishers && curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
	sudo apt-get install -y nodejs
COPY start.sh /usr/local/bin/
RUN chmod -R g=u /home/jovyan
RUN chmod ugo+x /usr/local/bin/start.sh
ENV GRANT_SUDO="yes"
RUN wget http://mirrors.ctan.org/macros/latex/contrib/tcolorbox.zip
RUN rm -fR /usr/share/texlive/texmf-dist/tex/latex/tcolorbox
RUN unzip tcolorbox.zip -d /usr/share/texlive/texmf-dist/tex/latex
RUN rm tcolorbox.zip
#COPY start-notebook.sh /usr/local/bin/
#COPY start-singleuser.sh /usr/local/bin/
#COPY start.sh /usr/local/bin

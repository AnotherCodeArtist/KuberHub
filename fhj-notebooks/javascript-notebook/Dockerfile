# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/minimal-notebook

USER $NB_USER

#Install nbgrader
RUN conda install nbgrader

RUN jupyter nbextension install --user --py nbgrader
RUN jupyter nbextension enable --user --py nbgrader
RUN jupyter serverextension enable --user --py nbgrader


WORKDIR /home/jovyan/work
RUN conda install -c conda-forge rise
USER root
RUN apt-get update
RUN apt-get install -y curl texlive-publishers && curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
	sudo apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*
RUN sudo npm install -g --unsafe-perm ijavascript
WORKDIR /usr/lib/node_modules/ijavascript/
RUN npm rebuild zeromq --unsafe-perm --update-binary
WORKDIR /home/jovyan/work
USER $NB_USER
RUN ijsinstall
USER root

COPY start.sh /usr/local/bin/
RUN chmod -R g=u /home/jovyan
RUN chmod ugo+x /usr/local/bin/start.sh
ENV GRANT_SUDO="yes"
RUN wget http://mirrors.ctan.org/macros/latex/contrib/tcolorbox.zip
RUN rm -fR /usr/share/texlive/texmf-dist/tex/latex/tcolorbox
RUN unzip tcolorbox.zip -d /usr/share/texlive/texmf-dist/tex/latex
RUN rm tcolorbox.zip

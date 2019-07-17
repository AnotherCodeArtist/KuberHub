# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/r-notebook

USER $NB_UID

#Install nbgrader
RUN conda install nbgrader

RUN jupyter nbextension install --user --py nbgrader
RUN jupyter nbextension enable --user --py nbgrader
RUN jupyter serverextension enable --user --py nbgrader

USER root
COPY start.sh /usr/local/bin/
RUN chmod -R g=u /home/jovyan
RUN chmod ugo+x /usr/local/bin/start.sh
ENV GRANT_SUDO="yes"

#COPY start-notebook.sh /usr/local/bin/
#COPY start-singleuser.sh /usr/local/bin/
#COPY start.sh /usr/local/bin

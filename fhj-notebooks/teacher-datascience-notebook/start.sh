#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

# Handle special flags if we're root
if [ $(id -u) == 0 ] ; then
    # Change UID of NB_USER to NB_UID if it does not match
    if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
        if [[ ! -z "$TEACHER_GID" ]] ; then
	    echo "Creating group teachers with ID $TEACHER_GID"
        groupadd -g $TEACHER_GID teachers
        echo "Creating user $JUPYTERHUB_USER"
	    adduser --uid $NB_UID --no-create-home --disabled-password --gecos "" --gid $TEACHER_GID $JUPYTERHUB_USER
        else 
            echo "Creating group students with ID $NB_GID"
	        groupadd -g $NB_GID students
	        echo "Creating user $JUPYTERHUB_USER"
	        adduser --uid $NB_UID --no-create-home --disabled-password --gecos "" --gid $NB_GID $JUPYTERHUB_USER
        fi

	#echo "Change ownership of jovyan's home folder"
	#chown -R $JUPYTERHUB_USER:$NB_UID /home/jovyan
	NB_USER_GROUP=$(id -gn jovyan)
	echo "Adding $JUPYTERHUB_USER to group $NB_USER_GROUP"
	usermod -a -G $NB_USER_GROUP $JUPYTERHUB_USER
	echo "Setting home directory of user $JUPYTERHUB_USER to /home/jovyan"
	usermod -d /home/jovyan $JUPYTERHUB_USER

    fi

    # Change GID of NB_USER to NB_GID if NB_GID is passed as a parameter
    #if [ "$NB_GID" ] ; then
        #echo "Change GID to $NB_GID"
        #groupmod -g $NB_GID -o $(id -g -n $NB_USER)
    #fi

    # Enable sudo if requested
    if [ ! -z "$GRANT_SUDO" ]; then
	echo "$JUPYTERHUB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
    fi

    # Exec the command as NB_USER
    echo "Execute the command as $NB_USER"
    echo "Command is:  exec sudo -E -H -u $JUPYTERHUB_USER PATH=$PATH PYTHONPATH=$PYTHONPATH stack exec $*"
    echo "Arguments: $*"
    echo "Programm: $1"
    echo "Programm Arguments: ${@:2}"
    #mkdir -p /home/jovyan/work/grader
    exec sudo -E -H -u $JUPYTERHUB_USER PATH=$PATH /opt/conda/bin/jupyterhub-singleuser --ip=0.0.0.0 --port=8888 --allow-root
else
    # Exec the command
    echo "Execute the command"
    exec $*
fi

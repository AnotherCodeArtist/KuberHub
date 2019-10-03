#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

echo "In start.sh with arguments: $@"
echo "Environment:"
env

# Exec the specified command or fall back on bash
if [ $# -eq 0 ]; then
    cmd=( "bash" )
else
    cmd=( "$@" )
fi

echo "Cmd=$cmd"

run-hooks () {
    # Source scripts or run executable files in a directory
    echo "Running hooks"
    if [[ ! -d "$1" ]] ; then
        echo "Nothing to do!"
        return
    fi
    echo "$0: running hooks in $1"
    for f in "$1/"*; do
        case "$f" in
            *.sh)
                echo "$0: running $f"
                source "$f"
                ;;
            *)
                if [[ -x "$f" ]] ; then
                    echo "$0: running $f"
                    "$f"
                else
                    echo "$0: ignoring $f"
                fi
                ;;
        esac
    done
    echo "$0: done running hooks in $1"
}

run-hooks /usr/local/bin/start-notebook.d
echo "Current user id: $(id -u)"

# Handle special flags if we're root
if [ $(id -u) == 0 ] ; then
    echo "Running as root!"
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

        NB_USER_GROUP=$(id -gn jovyan)
        echo "Adding $JUPYTERHUB_USER to group $NB_USER_GROUP"
        usermod -a -G $NB_USER_GROUP $JUPYTERHUB_USER
        echo "Setting home directory of user $JUPYTERHUB_USER to /home/jovyan"
        usermod -d /home/jovyan $JUPYTERHUB_USER
    fi

    if [ -f $CONFIGPATH ]; then
      home=$(eval echo ~$JUPYTERHUB_USER)
      echo "Copying $CONFIGPATH to $home"
      sudo -u $JUPYTERHUB_USER cp $CONFIGPATH $home/.jupyter
    else
      echo "WARNING: There is no nbgrader_config ($CONFIGPATH)"
    fi

    if [ ! -z "$GRANT_SUDO" ]; then
      echo "$JUPYTERHUB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
    fi

    # Add $CONDA_DIR/bin to sudo secure_path
    sed -r "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers | grep secure_path > /etc/sudoers.d/path

    # Exec the command as NB_USER with the PATH and the rest of
    # the environment preserved
    run-hooks /usr/local/bin/before-notebook.d
    echo "Executing the command: ${cmd[@]}"
    exec sudo -E -H -u $JUPYTERHUB_USER PATH=$PATH XDG_CACHE_HOME=/home/$NB_USER/.cache PYTHONPATH=${PYTHONPATH:-} "${cmd[@]}"
else
    echo "Not running as root: $(whoami)"
    if [[ "$NB_UID" == "$(id -u jovyan)" && "$NB_GID" == "$(id -g jovyan)" ]]; then
        # User is not attempting to override user/group via environment
        # variables, but they could still have overridden the uid/gid that
        # container runs as. Check that the user has an entry in the passwd
        # file and if not add an entry.
        STATUS=0 && whoami &> /dev/null || STATUS=$? && true
        if [[ "$STATUS" != "0" ]]; then
            if [[ -w /etc/passwd ]]; then
                echo "Adding passwd file entry for $(id -u)"
                cat /etc/passwd | sed -e "s/^jovyan:/nayvoj:/" > /tmp/passwd
                echo "jovyan:x:$(id -u):$(id -g):,,,:/home/jovyan:/bin/bash" >> /tmp/passwd
                cat /tmp/passwd > /etc/passwd
                rm /tmp/passwd
            else
                echo 'Container must be run with group "root" to update passwd file'
            fi
        fi

        # Warn if the user isn't going to be able to write files to $HOME.
        if [[ ! -w /home/jovyan ]]; then
            echo 'Container must be run with group "users" to update files'
        fi
    else
        # Warn if looks like user want to override uid/gid but hasn't
        # run the container as root.
        if [[ ! -z "$NB_UID" && "$NB_UID" != "$(id -u)" ]]; then
            echo 'Container must be run as root to set $NB_UID'
        fi
        if [[ ! -z "$NB_GID" && "$NB_GID" != "$(id -g)" ]]; then
            echo 'Container must be run as root to set $NB_GID'
        fi
    fi

    # Warn if looks like user want to run in sudo mode but hasn't run
    # the container as root.
    if [[ "$GRANT_SUDO" == "1" || "$GRANT_SUDO" == 'yes' ]]; then
        echo 'Container must be run as root to grant sudo permissions'
    fi

    # Execute the command
    run-hooks /usr/local/bin/before-notebook.d
    echo "Executing the command: ${cmd[@]}"
    exec "${cmd[@]}"
fi

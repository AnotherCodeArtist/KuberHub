#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
  # launched by JupyterHub, use single-user entrypoint
  echo "Launched by Jupyterhub with JUPYTERHUB_API_TOKEN=$JUPYTERHUB_API_TOKEN and arguments: $@"
  exec /usr/local/bin/start-singleuser.sh "$@"
elif [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
  echo "Starting Jupyter Lab"
  . /usr/local/bin/start.sh jupyter lab "$@"
else
  echo "Starting conventional notebook"
  . /usr/local/bin/start.sh jupyter notebook "$@"
fi

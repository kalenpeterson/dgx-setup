#!/bin/bash

# Input Vars
USER_NAME=${1}
GRAPH_ROOT=${2}

F_PromptContinue () {
  read -p "Are you sure [yn]? " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting!"
    exit 1
  fi
}

# Validate we are root
if [[ `id -u` -ne 0 ]]; then
  echo
  echo "ERROR: You must be root!"
  exit 1
fi

# Validate user
if [[ ! -z ${USER_NAME} && ${USER_NAME} != '' ]]; then
  id -u ${USER_NAME} >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo
    echo "ERROR: User is not Valid"
    exit 2
  fi
else
  echo
  echo "ERROR: No User provided"
  exit 2
fi

# Validate Path
if [[ ! -z ${GRAPH_ROOT} && ${GRAPH_ROOT} != '' && ${GRAPH_ROOT} != '/' ]]; then
  if [[ ! -d ${GRAPH_ROOT} ]]; then
    echo
    echo "ERROR: Graphroot path does not exist"
    exit 3
  fi
else
  echo
  echo "ERROR: No Graphroot Path proviced"
  exit 3
fi

USER_UID=$(id -u ${USER_NAME})
USER_GID=$(id -g ${USER_NAME})
USER_HOME=$(eval echo ~${USER_NAME})

echo
echo "Resetting ${USER_NAME}, validate details below"
echo "Username: ${USER_NAME}"
echo "UID: ${USER_UID}"
echo "GID: ${USER_GID}"
echo "User Home: ${USER_HOME}"
echo "GraphRoot: ${GRAPH_ROOT}"
echo "User Image Storage: ${GRAPH_ROOT}/${USER_NAME}"
echo
F_PromptContinue

# Reset Runroot
mkdir -p /tmp/run-${USER_UID}
chown ${USER_NAME} /tmp/run-${USER_UID}
chmod 700 /tmp/run-${USER_UID}

# Setup Podman Storage
mkdir -p ${GRAPH_ROOT}/${USER_NAME}
chown ${USER_UID}:${USER_GID} ${GRAPH_ROOT}/${USER_NAME}
chmod 750 ${GRAPH_ROOT}/${USER_NAME}

# Reset Podman config
rm -f ${USER_HOME}/.config/containers/storage.conf
su - ${USER_NAME} -c "podman info >/dev/null"

# Update User Storage path
DEFAULT_PATH=${USER_HOME}/.local/share/containers/storage
SHARED_PATH=${GRAPH_ROOT}/${USER_NAME}
sed -i "s#${DEFAULT_PATH}#${SHARED_PATH}#g" ${USER_HOME}/.config/containers/storage.conf

# Test Podman
echo
su - ${USER_NAME} -c "podman info >/dev/null && echo 'Reset OK' || echo 'Failed to Reset'"

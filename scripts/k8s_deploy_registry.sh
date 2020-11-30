#!/bin/bash
set -x

# Get absolute path for script and root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="${SCRIPT_DIR}/.."
CHART_VERSION="1.9.4"

# Allow overriding config dir to look in
config_dir=${DEEPOPS_CONFIG_DIR:-"${ROOT_DIR}/config"}
if [ ! -d "${config_dir}" ]; then
	echo "Can't find configuration in ${config_dir}"
	echo "Please set DEEPOPS_CONFIG_DIR env variable to point to config location"
	exit 1
fi

if ! kubectl version ; then
    echo "Unable to talk to Kubernetes API"
    exit 1
fi

# Add Helm stable repo if it doesn't exist
HELM_CHARTS_REPO_STABLE="${HELM_CHARTS_REPO_STABLE:-https://kubernetes-charts.storage.googleapis.com}"
if ! helm repo list | grep stable >/dev/null 2>&1 ; then
    helm repo add stable "${HELM_CHARTS_REPO_STABLE}"
fi

# We need to dynamically set up Helm args, so let's use an array
helm_arguments=("--version" "${CHART_VERSION}"
                "--values" "${config_dir}/helm/registry.yml"
)

# Set up the Container Registry
if ! helm status docker-registry >/dev/null 2>&1; then
	helm install docker-registry stable/docker-registry "${helm_install_args[@]}"
fi

kubectl wait --timeout=120s --for=condition=Ready -l app=docker-registry pod

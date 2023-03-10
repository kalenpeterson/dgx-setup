#!/bin/bash

SERVICE_FILE=cluster_services.csv

F_PromptContinue () {
  read -p "Are you sure [yn]? " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting!"
    exit 1
  fi
}

F_Log () {
    echo "[$(date)] $1"
}

echo
F_Log "The following services will be restarted:"
echo
echo "----------------------------------------------------------------------------"
cat $SERVICE_FILE |column -t -s ,
echo "----------------------------------------------------------------------------"
F_PromptContinue
echo

F_Log "Starting Service Termination"
while IFS="," read -r NAMESPACE SERVICE_TYPE SERVICE_NAME SERVICE_RESTART
do
    if [[ $SERVICE_RESTART != 'true' ]]; then
        continue
    fi

    F_Log "Restarting $SERVICE_NAME"
    PODS=$(kubectl get pods -n $NAMESPACE |grep -P "^$SERVICE_NAME*" |grep -v Terminating |awk '{print $1}')
    for POD in $PODS
    do
        kubectl delete -n $NAMESPACE --wait=true pod/$POD
    done
done < <(sed '1d' $SERVICE_FILE)
F_Log "Completed Service Termination"
echo

F_Log "Checking for Services to become ready"
while IFS="," read -r NAMESPACE SERVICE_TYPE SERVICE_NAME SERVICE_RESTART
do
    if [[ $SERVICE_RESTART != 'true' ]]; then
        continue
    fi

    F_Log "Waiting for $SERVICE_NAME to become Ready"
    PODS=$(kubectl get pods -n $NAMESPACE |grep -P "^$SERVICE_NAME*" |grep -v Terminating |awk '{print $1}')
    for POD in $PODS
    do
        kubectl wait --for=condition=Ready -n $NAMESPACE pod/$POD --timeout=120s || echo "Failed to restart $SERVICE_NAME"
    done
done < <(sed '1d' $SERVICE_FILE)
echo

F_Log "All service have restarted successfully"
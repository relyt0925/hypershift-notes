#!/usr/bin/env bash
echo "example values below"
NODEPOOL_NAMESPACE=master
NODEPOOL_NAME=clusteridc
CLUSTER_NAMESPACE=master-clusteridc
MACHINEDEPLOYMENT_NAME=tyler-test1-2021-03-06--584ef697-clusteridc
NEW_MACHINE_TEMPLATE_NAME=tyler-test1-2021-03-06--584ef697-clusteridc
MACHINE_NAME_TO_UPGRADE=tyler-test1-2021-03-06--584ef697-clusteridc-5865866cfc-wktvr


echo "sample logic below"

echo "step: ensuring nodepool/machinedeployment ready for in place update strategy. KEY ASSUMPTION FOR CONTROL: maxUnavailable -1 and maxSurge need to be 0"
kubectl patch --type='json' -n "$NODEPOOL_NAMESPACE" nodepool/"$NODEPOOL_NAME" -p='[{"op": "replace", "path": "/spec/nodePoolManagement/maxSurge", "value": 0}]'
kubectl patch --type='json' -n "$NODEPOOL_NAMESPACE" nodepool/"$NODEPOOL_NAME" -p='[{"op": "replace", "path": "/spec/nodePoolManagement/maxUnavailable", "value": 0}]'
kubectl patch --type='json' -n "$CLUSTER_NAMESPACE" machinedeployment/"$MACHINEDEPLOYMENT_NAME" -p='[{"op": "replace", "path": "/spec/strategy/rollingUpdate/maxSurge", "value": 0}]'
kubectl patch --type='json' -n "$CLUSTER_NAMESPACE" machinedeployment/"$MACHINEDEPLOYMENT_NAME" -p='[{"op": "replace", "path": "/spec/strategy/rollingUpdate/maxUnavailable", "value": -1}]'

echo "step: simulating a rollout of a new machine deployment. In my example resources I change the ami in the new machine template to simulate updating images on a version rollout"
PATCHSTRING='[{"op": "replace", "path": "/spec/template/spec/infrastructureRef/name", "value":"'${NEW_MACHINE_TEMPLATE_NAME}'"}]'
kubectl patch --type='json' -n "$CLUSTER_NAMESPACE" machinedeployment/"$MACHINEDEPLOYMENT_NAME" -p="$PATCHSTRING"

echo "pause and take it in. The new replica set has rolled out but no provisioning will start yet."
echo "user controls the update process by deleting old nodes."
echo "When an old node deleted, it will spin up in new replica set with updated image."
echo "Will show an example of this by deleting a node in the set."
sleep 10

echo "first can see that by looking at machinesets"
kubectl get -n "$CLUSTER_NAMESPACE"  machinesets
sleep 10

echo "ensuring machine not already triggered for upgrade"
if ! kubectl -n "$CLUSTER_NAMESPACE" get machines "$MACHINE_NAME_TO_UPGRADE" -o jsonpath='{.metadata.deletionTimestamp}' >/tmp/deletionTimestamp; then
	echo "machine already deleted or network error"
	exit 1
fi
DELETION_TIMESTAMP=$(cat /tmp/deletionTimestamp)
if [[ -n "$DELETION_TIMESTAMP" ]]; then
  echo "machine is in the process of being deleted"
  exit 1
fi

echo "now going to simulate in place upgrade of one machine"
OWNING_MACHINESET_OF_MACHINE=$(kubectl get -n "$CLUSTER_NAMESPACE" machines "$MACHINE_NAME_TO_UPGRADE" -o jsonpath='{.metadata.ownerReferences[0].name}')
CURRENT_REPLICAS=$(kubectl get -n "$CLUSTER_NAMESPACE" machineset "$OWNING_MACHINESET_OF_MACHINE" -o jsonpath='{.spec.replicas}')
NEW_REPLICAS=$((CURRENT_REPLICAS - 1))

kubectl -n "$CLUSTER_NAMESPACE" delete machines/"$MACHINE_NAME_TO_UPGRADE" --wait=false
PATCHSTRING='[{"op": "replace", "path": "/spec/replicas", "value":'${NEW_REPLICAS}'}]'
kubectl patch --type='json' -n "$CLUSTER_NAMESPACE" machineset/"$OWNING_MACHINESET_OF_MACHINE" -p="${PATCHSTRING}"


echo "end of role. wait a few minutes for the machine to fully delete."
echo "if you query the machinesets again you will see an additional machine added to the new machineset"
echo "this script can be reran on a per machine basis to simulate an entire upgrade"
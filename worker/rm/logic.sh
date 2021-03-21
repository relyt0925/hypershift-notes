#!/usr/bin/env bash
echo "example values below"
NODEPOOL_NAMESPACE=master
NODEPOOL_NAME=clusteridc
CLUSTER_NAMESPACE=master-clusteridc
MACHINE_NAME=tyler-test1-2021-03-06--584ef697-clusteridc-7689c68fbc-8thvz

echo "sample logic below"
echo "step: gathering current node count info and sizing based on node getting removed"
CURRENT_COUNT=$(kubectl -n "$NODEPOOL_NAMESPACE" get nodepool "$NODEPOOL_NAME" -o jsonpath='{.spec.nodeCount}')
NEW_COUNT=$((CURRENT_COUNT - 1))
echo "step: verifying that machine isn't in the process of being deleted or already deleted"
if ! kubectl -n "$CLUSTER_NAMESPACE" get machines "$MACHINE_NAME" -o jsonpath='{.metadata.deletionTimestamp}' >/tmp/deletionTimestamp; then
	echo "machine already deleted or network error"
	exit 1
fi
DELETION_TIMESTAMP=$(cat /tmp/deletionTimestamp)
if [[ -n "$DELETION_TIMESTAMP" ]]; then
  echo "machine is in the process of being deleted"
  exit 1
fi
echo "step: proceeding to delete machine and scale node-pool"
kubectl -n "$CLUSTER_NAMESPACE" delete machines/"$MACHINE_NAME" --wait=false
PATCHSTRING='[{"op": "replace", "path": "/spec/nodeCount", "value":'${NEW_COUNT}'}]'
kubectl patch --type='json' -n "$NODEPOOL_NAMESPACE" nodepool/"$NODEPOOL_NAME" -p="${PATCHSTRING}"

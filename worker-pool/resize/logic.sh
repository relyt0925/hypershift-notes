#!/usr/bin/env bash
NODEPOOL_NAMESPACE=master
NODEPOOL_NAME=clusteridc
NEW_SIZE=8

echo "step: patching proper resource to execute scaleout"
PATCHSTRING='[{"op": "replace", "path": "/spec/nodeCount", "value":'${NEW_SIZE}'}]'
kubectl patch --type='json' -n "$NODEPOOL_NAMESPACE" nodepool/"$NODEPOOL_NAME" -p="${PATCHSTRING}"

echo "note in IBM concepts of worker-pools: a worker pool can have multiple zones assigned to it"
echo "this illustrates the single zone case. If the worker-pool is multizone this patch command"
echo "would be executed on the node pool associated in each zone"


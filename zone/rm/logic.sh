#!/usr/bin/env bash
NODEPOOL_NAMESPACE=master
NODEPOOL_NAME=clusteridc-mypool-us-west-1a

echo "step: zone remove wil remove the node pool associated with a zone"
kubectl delete -n "$NODEPOOL_NAMESPACE" nodepool/"$NODEPOOL_NAME" --wait=false


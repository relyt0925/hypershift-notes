#!/usr/bin/env bash
echo "example values below"
CLUSTER_NAMESPACE=master-clusteridc
MACHINE_TO_REPLACE=tyler-test1-2021-03-06--584ef697-clusteridc-5865866cfc-gjdnj

echo "sample logic below"

echo "step: issue delete on machine. once complete the cluster api controllers will spin another node in it's place"
kubectl -n "$CLUSTER_NAMESPACE" delete machines/"$MACHINE_TO_REPLACE" --wait=false

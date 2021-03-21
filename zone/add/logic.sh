#!/usr/bin/env bash
echo "step: zone add to a worker pool will end up creating a node pool. node pools are scoped to one zone"
cat <<EOF >/tmp/example-nodeppol
kind: NodePool
metadata:
  name: clusteridc-mypool-us-west-1a
  namespace: master
spec:
  clusterName: clusteridc
  nodeCount: 3
  nodePoolManagement:
    maxSurge: 0
    maxUnavailable: 0
  platform:
    aws:
      instanceProfile: tyler-test1-2021-03-06-vpc-worker
      instanceType: m4.large
      securityGroups:
      - id: sg-054519a33b9e35520
      subnet:
        id: subnet-007a63eb0ade10d2e
      zone: us-west-1a
EOF
kubectl apply -f /tmp/example-nodeppol

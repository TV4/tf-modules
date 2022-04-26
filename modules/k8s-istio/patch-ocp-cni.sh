#!/bin/env bash

mkdir /tmp/kustomize-ocp
cat <<EOF > /tmp/kustomize-ocp/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- all.yaml

patches:
- path: /tmp/kustomize-ocp/patch.yaml
  target:
    kind: DaemonSet
    name: "istio-cni-node"
EOF

cat <<EOF > /tmp/kustomize-ocp/patch.yaml
apiVersion: v1
kind: DaemonSet
metadata:
  name: istio-cni-node
spec:
  template:
    spec:
      containers:
      - name: install-cni
        securityContext:
          privileged: true
EOF


cat <&0 > /tmp/kustomize-ocp/all.yaml

kustomize build /tmp/kustomize-ocp && rm -rf /tmp/kustomize-ocp



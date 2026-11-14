#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for domain in sales housing finance data; do
    kubectl --context=task4 apply -n "$domain" -f manifests/domain-bindings.yml
done
kubectl --context=task4 apply -f manifests/cluster-bindings.yml

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

kubectl --context=task4 apply -f manifests/namespaces.yml
for domain in sales housing finance data; do
    kubectl --context=task4 apply -n "$domain" -f manifests/domain-serviceaccounts.yml
done
kubectl --context=task4 apply -f manifests/cluster-serviceaccounts.yml

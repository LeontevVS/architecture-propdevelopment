#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

kubectl --context=task4 apply -f manifests/cluster-roles.yml
for domain in sales housing finance data; do
    kubectl --context=task4 apply -n "$domain" -f manifests/secret-reader.yml
done

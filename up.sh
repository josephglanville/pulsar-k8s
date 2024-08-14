#!/bin/bash

set -euo pipefail

# Add helm repos
helm repo add kaap https://datastax.github.io/kaap
helm repo add streamnative https://charts.streamnative.io
helm repo add cnpg https://cloudnative-pg.github.io/charts

# Setup test cluster
kind create cluster --name pulsar --config kind.yaml
kubectx kind-pulsar
kind load docker-image --name=pulsar docker.io/apachepulsar/pulsar-jpg:3.3.1

# Install kaap-stack
helm install pulsar kaap/kaap-stack --values kaap-stack.yaml

# Install pulsar-resources-operator
helm install pulsar-resources streamnative/pulsar-resources-operator --values pulsar-resources.yaml

# Overwrite the CRDs because of bad pulsar-resources-operator chart release
# See: https://github.com/streamnative/pulsar-resources-operator/issues/234
kubectl apply -f crds

# Install PostgresSQL operator
helm install cnpg --namespace cnpg-system --create-namespace cnpg/cloudnative-pg

# Wait for CNPG operator to come up
kubectl -n cnpg-system wait --for=condition=Available deployment/cnpg-cloudnative-pg --timeout=300s

# Create secrets
kubectl apply -f secrets

# Create PostgreSQL cluster
helm install postgres cnpg/cluster --values postgres.yaml

# Wait for Pulsar cluster to come up
kubectl wait --for=condition=Ready pulsarclusters/pulsar --timeout=300s

# Wait for PostgreSQL to become ready
kubectl wait --for=condition=Ready clusters/postgres-cluster --timeout=300s

# Create Pulsar resources
kubectl apply -f manifests

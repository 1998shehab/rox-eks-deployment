# Rox Custody DevOps Deployment

This repository contains the Kubernetes deployment manifests and configuration for the Rox Custody infrastructure.

## Prerequisites

To interact with this repository and deploy services, you need the following tools installed:

- **kubectl**: Kubernetes command-line tool for interacting with the cluster.
- **aws-cli**: For interacting with AWS services (ECR, EKS).
- **helm** (Optional): If any charts are used (though primarily raw manifests here).

## Repository Structure

The repository is organized by service and infrastructure component:

### Core Services
- `solution-api/`: Contains deployment for the Custody Solution API.
    - `solution.sh`: Script to build, push image, and update deployment tags.
- `custody-keys-bridge/`: Service for bridging custody keys, uses Secrets Store CSI.
- `Custody_Super_Admin_Api/`: API for Super Admin functionality.
- `Custody_Super_Admin_Dashboard/`: Dashboard UI for Super Admins.
- `Solution_Corporate_Dashboard/`: Corporate dashboard UI.
- `Custody-policy-manager/`: Policy management service.
- `custody-private-server/`: Private server component.

### Infrastructure & Config
- `rox-ingress/`: Ingress configuration using AWS Load Balancer Controller.
- `secrets-manager/`: `SecretProviderClass` definitions for referencing AWS Secrets Manager secrets via the CSI driver.
- `sc.yml`: StorageClass definition (`gp2-csi`).
- `values.yml`: General values file (likely for Templating or Reference).

### Logging
- `efk-eks-logging/`: Configuration for the EFK (Elasticsearch, Fluentd, Kibana) stack.
    - `fluentd-config.yaml`: Custom Fluentd configuration.

## Deployment Instructions

### General Deployment

Most services are deployed using standard `kubectl` commands.

```bash
# Example: Deploying the Keys Bridge
kubectl apply -f custody-keys-bridge/custody-keys-bridge.yml
kubectl apply -f custody-keys-bridge/custody-keys-bridge-service.yml
```



### Secrets Management

This project uses the **Secrets Store CSI Driver** to mount secrets from AWS Secrets Manager as volumes.

Ensure the `SecretProviderClass` resources in `secrets-manager/` are applied first:

```bash
kubectl apply -f secrets-manager/keys_bridge_secretprovider.yml
# ... apply others as needed
```

Deployments (like `custody-keys-bridge`) reference these classes to mount secrets at runtime.

### Logging (EFK Stack)

The logging stack definitions are located in `efk-eks-logging/`.

```bash
kubectl apply -f efk-eks-logging/01_Namespace.yml
kubectl apply -f efk-eks-logging/02_es.yml
kubectl apply -f efk-eks-logging/03_kibana.yml
kubectl apply -f efk-eks-logging/fluentd-config.yaml
kubectl apply -f efk-eks-logging/fluentd.yaml
```

- **Fluentd** is configured to collect container logs and ship them to Elasticsearch.
- **Kibana** is available for visualizing logs.


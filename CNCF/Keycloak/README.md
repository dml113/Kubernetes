# Keycloack Helm Chart Installation

## When you erase and reinstall Helmchart, delete pvc directly using the command below:
  ```bash
  k get pvc -n <keycloak namespace>
  k delete pvc data-keycloak-postgresql-0 -n <keycloak namespace> 
  ```

- Refer Site
  [https://artifacthub.io/packages/helm/bitnami/keycloak],     [https://github.com/bitnami/charts.git]

### 1. Keycloak Helm Repository add
  ```bash
  helm repo add bitnami https://charts.bitnami.com/bitnami
  ```

### 2. Download Helm Charts for the Storage You Added
  ```bash
  git clone https://github.com/bitnami/charts.git
  cd charts/bitnami/keycloak
  ```

### 3. Configure values.yaml
```bash
vi values.yaml

...

## Keycloak authentication parameters
## ref: https://github.com/bitnami/bitnami-docker-keycloak#admin-credentials
##
auth:
  ## @param auth.createAdminUser Create administrator user on boot
  ##
  createAdminUser: true
  ## @param auth.adminUser Keycloak administrator user
  ##
  adminUser: admin
  ## @param auth.adminPassword Keycloak administrator password for the new user
  ##
  adminPassword: ${adminPassword}

...
```

### 4. Deploy Keycloak Helm Chart
  ```bash
  k create ns keycloak
  helm install keycloak bitnami/keycloak -f values.yaml --namespace keycloak
  ```

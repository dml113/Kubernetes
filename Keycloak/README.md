# Keycloack Helm Chart Installation

- Refer Site
  [https://artifacthub.io/packages/helm/bitnami/keycloak]
  [https://github.com/bitnami/charts.git]

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

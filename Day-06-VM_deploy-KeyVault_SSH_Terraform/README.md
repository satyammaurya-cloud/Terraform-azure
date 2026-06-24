# 🔐 Azure Linux VM Deployment using Terraform + Azure Key Vault (SSH Authentication)

## Overview

This project demonstrates how to deploy a secure Linux Virtual Machine in Azure using Terraform while storing sensitive configuration data in Azure Key Vault.

Instead of hardcoding credentials in Terraform code, the VM administrator username and SSH public key are securely retrieved from Azure Key Vault during deployment.



## Step 1 - Generate SSH Key Pair into Local

```bash
ssh-keygen -t rsa -b 4096
```

Generated files:

```text
~/.ssh/id_rsa
~/.ssh/id_rsa.pub
```

## Step 2 - Store Secrets in Azure Key Vault

Secret 1:

```text
vm-admin-user
```

Value:

```text
azureadmin
```

Secret 2:

```text
vm-public-key
```

Value:

```text
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ...
```

## Step 3 - Terraform Deployment

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## Resources Created

- Virtual Network
- Subnet
- Network Security Group
- Public IP
- Network Interface
- Ubuntu Linux VM

## Connect to VM

```bash
ssh -i ~/.ssh/id_rsa azureadmin@<PUBLIC-IP>
```

## Security Benefits

- No hardcoded credentials
- Centralized secret management
- SSH key authentication
- Azure Key Vault integration

## Production Improvements

- Azure Bastion
- Managed Identity
- OIDC Authentication
- Remote State Backend
- Private Subnets
- NSG Restrictions


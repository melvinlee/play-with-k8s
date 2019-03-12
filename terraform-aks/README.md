[![Build status](https://thorpoc.visualstudio.com/Thor/_apis/build/status/Infrastructure-CI)](https://thorpoc.visualstudio.com/Thor/_build/latest?definitionId=4)

# Infrastructure

This repository contain terraform template to provision azure Pass/Iaas resources.

## Required Tooling

- Terraform
- Azure CLI

## Pre-quisites

Create a service principal for AKS

```sh
az ad sp create-for-rbac -n "aks-sp" --skip-assignment
```

Update varaibles.tfvars file and add your service principal clientid and clientsecret as variables. Examples:

```sh
client_id = "2f61810e-7f8d-49fd-8c0e-c4ffake51f9f"
client_secret = "57f8b670-012d-42b2-a0f8-c3fakee239ad"
```

Run `terraform init` then `terraform plan` to see what will be created, finally if it looks good run `terraform apply`

```sh
terraform init
terraform plan -var-file=variables.tfvars -out=azure-vm.tfplan
terraform apply azure-vm.tfplan
```

## Cleanup

You can cleanup the Terraform-managed infrastructure.

```sh
terraform destroy -var-file=variables.tfvars -force
```
# infra-micondominio
cd infra/
terraform plan -out=tfplan -var-file="../environment/sbx/env.sbx.tfvars"
terraform apply -var-file="../environment/sbx/env.sbx.tfvars"
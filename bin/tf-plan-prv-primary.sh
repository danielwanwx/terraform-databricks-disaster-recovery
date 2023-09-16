pushd primary

echo "Start to init terraform for Azure Databricks"
terraform init -reconfigure -backend-config=./conf/backend-prv.hcl

echo "Start to generate terraform plan for Azure Databricks"
terraform plan -out main-prv-primary.tfplan -var-file=./vardefs/vars-prv.tfvars

popd

```
# Config your AWS credential
aws configure --profile da-q2  

# Create terraform s3 backend for remote state
aws s3api create-bucket \
    --bucket terraform-da-q2 \
    --create-bucket-configuration LocationConstraint=ap-east-1 \
    --profile da-q2

# Validate your terraform scripts, check qa.tfvars carefully
terraform plan --var-file=qa.tfvar

# Apply terraform to deploy your infra to aws
terraform apply --var-file=qa.tfvar

```
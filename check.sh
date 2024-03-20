#!/bin/bash

# Define AMI name to look for
ami_name="packer-terraform-ami"

# Run AWS EC2 describe images based on filters and query name
output=$(aws ec2 describe-images \
    --filters "Name=name,Values=$ami_name" \
    --region us-west-2 \
    --query "Images[0].Name" \
    --output text \
    2>/dev/null)

echo "AWS EC2 describe-images output: $output"

# Check if the AMI image output is None
if [[ "$output" == "None" ]]; then
    echo "AMI with name '$ami_name' does not exist. Creating..."
    # Run Packer build command to create the AMI
    packer init .
    packer fmt aws-terra-ubuntu.pkr.hcl
    packer build aws-terra-ubuntu.pkr.hcl
    
    # Check if Packer build was successful
    if [ $? -eq 0 ]; then
        echo "Packer build completed successfully. Proceeding to create an instance with Terraform..."
        # Run Terraform commands to create an instance
        terraform init
        terraform plan
        echo "Creating AWS instance..."
        terraform apply -auto-approve
    else
        echo "Packer build failed. Exiting..."
        exit 1
    fi
else
    echo "AMI with name '$ami_name' exists."
    echo "Proceeding to create an instance with Terraform..."
    # Run Terraform commands to create an instance
    terraform init
    terraform plan
    echo "Creating AWS instance..."
    terraform apply -auto-approve
fi
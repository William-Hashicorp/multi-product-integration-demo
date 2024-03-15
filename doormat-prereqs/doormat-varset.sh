#!/bin/bash

# Perform a login
doormat login -f

# Extract the account ID
account=$(doormat aws list | grep arn | awk -F':' '{print $5}')

# Export AWS credentials
eval $(doormat aws export --account ${account})

# Push configuration to Terraform Cloud
# Change to use your own TFC varset ID
doormat aws tf-push variable-set -a ${account} \
  --id varset-cDfJGSfDh3E6UyZn 

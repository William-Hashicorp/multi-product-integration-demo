#!/bin/bash


lease_path="mongodb/creds/demo/"

# Fetch the list of lease IDs and iterate over them
lease_ids=$(vault list -format=json sys/leases/lookup/$lease_path | jq -r '.[]')

for lease_id in $lease_ids; do
    echo "Fetching details for lease ID: $lease_id"
    vault lease lookup $lease_path$lease_id
    echo "-------------------------------------"
done


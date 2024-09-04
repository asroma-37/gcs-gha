#!/bin/bash

# Prompt the user to enter multiple service account key resource names separated by commas
read -p "Enter the full resource names for the service account keys to disable (separated by commas): " resource_names

# Convert the input string into an array, separated by commas
IFS=',' read -r -a resource_name_array <<< "$resource_names"

# Loop through each resource name and disable the corresponding service account key
for resource_name in "${resource_name_array[@]}"; do
  # Trim any leading/trailing whitespace
  resource_name=$(echo "$resource_name" | xargs)

  echo "Disabling key: $resource_name"

  # Disable the service account key using the gcloud command
  gcloud iam service-accounts keys disable "$resource_name" --quiet

  if [ $? -eq 0 ]; then
    echo "Successfully disabled key: $resource_name"
  else
    echo "Failed to disable key: $resource_name"
  fi
done

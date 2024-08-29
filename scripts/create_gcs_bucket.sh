#!/bin/bash

# Ensure the script is executed with a project ID argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <project_id>"
  exit 1
fi

project_id=$1

# Function to get the environment type label for a project
get_environment_type() {
    local project_id=$1
    gcloud projects describe $project_id --format="value(labels.environmenttype)"
}

# Function to create a GCS bucket
create_bucket() {
    local project_id=$1
    local environment_type=$2
    local kms_key

    if [[ "$environment_type" == "prod" ]]; then
        kms_key="projects/kms-prod-429600/locations/us-east4/keyRings/gkr-useast4/cryptoKeys/gk-${project_id}"
    elif [[ "$environment_type" == "nonprod" ]]; then
        kms_key="projects/kms-nonprod/locations/us-east4/keyRings/gkr-useast4/cryptoKeys/gk-${project_id}"
    else
        echo "Error: Unable to determine environment type for project $project_id"
        return 1
    fi

    bucket_name="${project_id}-gh-actions-test"

    echo "Creating bucket: gs://$bucket_name with KMS key: $kms_key"

    # Attempt to create the bucket
    if gcloud storage buckets create gs://$bucket_name \
        --default-storage-class=standard \
        --location=us-east4 \
        --default-encryption-key=$kms_key \
        --public-access-prevention \
        --uniform-bucket-level-access \
        --soft-delete-duration=7d; then
        echo "GCS bucket created: gs://$bucket_name"
        return 0
    else
        echo "Error: Failed to create bucket gs://$bucket_name"
        return 1
    fi
}

# Function to update a GCS bucket with object versioning
update_bucket_versioning() {
    local project_id=$1
    bucket_name="${project_id}-gh-actions-test"

    echo "Updating bucket with versioning: gs://$bucket_name"

    # Attempt to update the bucket
    if gcloud storage buckets update gs://$bucket_name --versioning; then
        echo "Updated bucket with versioning: gs://$bucket_name"
        return 0
    else
        echo "Error: Failed to update bucket gs://$bucket_name with versioning"
        return 1
    fi
}

# Main execution
environment_type=$(get_environment_type $project_id)

if [[ -z "$environment_type" ]]; then
    echo "Error: Failed to determine environment type for project $project_id"
    exit 1
fi

echo "Project ID: $project_id"
echo "Environment Type: $environment_type"

create_bucket $project_id $environment_type
if [[ $? -eq 0 ]]; then
    update_bucket_versioning $project_id
fi

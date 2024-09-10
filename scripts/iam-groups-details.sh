#!/bin/bash

# Function to get IAM policies and filter out groups
get_groups_with_permissions() {
    project_id=$1
    echo "Fetching IAM policies for project: $project_id"
    
    # Fetch the IAM policies for the project
    iam_policies=$(gcloud projects get-iam-policy "$project_id" --format=json)

    # Extract the roles and members that are groups
    echo "role,group,email" > "${project_id}_groups.csv"
    echo "$iam_policies" | jq -r '.bindings[] | select(.members[] | startswith("group:")) | [.role, .members[]] | @csv' >> "${project_id}_groups.csv"

    echo "Permissions for groups saved to ${project_id}_groups.csv"
}

# Prompt the user for project IDs (comma-separated)
read -p "Enter the Project IDs (comma-separated): " project_ids

# Remove spaces and convert the input to an array
IFS=',' read -r -a project_array <<< "${project_ids// /}"

# Check if any project IDs were provided
if [ ${#project_array[@]} -eq 0 ]; then
    echo "No project IDs provided. Exiting."
    exit 1
fi

# Loop over each project and fetch the groups with permissions
for project_id in "${project_array[@]}"
do
    get_groups_with_permissions "$project_id"
done

echo "All done!"

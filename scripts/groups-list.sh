#!/bin/bash

# Ask for project IDs as input, separated by commas
read -p "Enter project IDs separated by commas: " project_ids

# Convert the input into an array of project IDs
IFS=',' read -ra projects <<< "$project_ids"

# Create or clear the CSV file
output_file="grouplist.csv"
echo "Group Name,Project ID" > $output_file

# Iterate over each project ID
for project in "${projects[@]}"; do
    echo "Processing project: $project"
    
    # Fetch IAM policy for the project and extract group names
    gcloud projects get-iam-policy "$project" --format="json" | \
    jq -r '.bindings[] | select(.members[] | startswith("group:")) | "\(.members[]),'"$project"'"' | \
    grep "^group:" | sed 's/group://g' >> $output_file
done

echo "Group list exported to $output_file"

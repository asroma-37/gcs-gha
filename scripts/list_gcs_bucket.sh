#!/bin/bash

# Input: Project ID
PROJECT_ID=$1

# Authenticate with gcloud if needed
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# Set the project ID
gcloud config set project $PROJECT_ID

# List all GCS buckets in the specified project
gcloud storage buckets list --project $PROJECT_ID

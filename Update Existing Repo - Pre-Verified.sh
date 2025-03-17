#!/bin/bash

# Script to update a GitHub repository using an access token for authentication

# Step 1: Ensure we are in a Git repository
if [ ! -d ".git" ]; then
  echo "Error: This is not a Git repository. Please run this script inside a Git repository folder."
  exit 1
fi

# Step 2: Get the local repository name and replace spaces with dashes
local_repo_name=$(basename "$PWD")   # Get the current directory name
github_repo_name=${local_repo_name// /-}  # Replace spaces with dashes

echo "Local repository name: $local_repo_name"
echo "GitHub repository name: $github_repo_name"

# Step 3: Read the GitHub access token from the file
access_token_file="A:\Programming\Access Tokens\Github Access Token - Repo.txt"

if [ ! -f "$access_token_file" ]; then
  echo "Error: Access token file not found at $access_token_file"
  exit 1
fi

access_token=$(cat "$access_token_file" | tr -d '\n') # Remove any trailing newline

# Step 4: Configure Git remote with access token
git remote set-url origin "https://$access_token@github.com/kay-who-codes/$github_repo_name.git"

# Step 5: Add all changes (modified, new, and deleted files)
git add -A

# Step 6: Commit the changes
echo "Enter commit message (leave blank for default):"
read commit_msg

if [ -z "$commit_msg" ]; then
  commit_msg="Update repository with latest changes"
fi

git commit -m "$commit_msg"

# Step 7: Push changes to the GitHub repository
git push origin main

# Completion message
echo "Repository updated and pushed to GitHub with name: $github_repo_name"

#!/bin/bash

# Script to create (if needed) and push to a GitHub repository using an access token

# Function to check if repository exists on GitHub
repo_exists() {
    curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $access_token" "https://api.github.com/repos/kay-who-codes/$github_repo_name"
}

# Ensure we are in a Git repository; if not, initialise one
if [ ! -d ".git" ]; then
    git init || { echo "Error: Failed to initialise Git repository"; exit 1; }
fi

# Determine repository name based on current folder name
local_repo_name=$(basename "$PWD")
github_repo_name=${local_repo_name// /-}

# Read GitHub access token (update the path as needed)
access_token_file="A:/Programming/Access Tokens/Github Access Token - Repo.txt"
if [ ! -f "$access_token_file" ]; then
    echo "Error: Access token file not found at $access_token_file"
    exit 1
fi
access_token=$(tr -d '\n' < "$access_token_file")

# Check if the GitHub repository exists; if not, create it
response_code=$(repo_exists)
if [ "$response_code" = "404" ]; then
    curl_output=$(curl -H "Authorization: token $access_token" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"name\":\"$github_repo_name\", \"private\":false}" \
        https://api.github.com/user/repos)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create repository."
        exit 1
    fi
elif [ "$response_code" != "200" ]; then
    echo "Error: Unexpected response code from GitHub API: $response_code"
    exit 1
fi

# Configure Git remote
git remote remove origin 2> /dev/null
git remote add origin "https://$access_token@github.com/kay-who-codes/$github_repo_name.git" || { echo "Error: Failed to set remote URL."; exit 1; }

# Stage all files, folders and subfolders
git add -A || { echo "Error: Failed to stage changes."; exit 1; }

# Commit changes (use a custom commit message if provided)
commit_msg="Update repository with latest changes"
echo "Enter commit message (leave blank for default):"
read -r user_commit_msg
[ -n "$user_commit_msg" ] && commit_msg="$user_commit_msg"
git commit -m "$commit_msg" || { echo "Error: Failed to commit changes."; exit 1; }

# Push changes to GitHub (tries branch 'main' then 'master')
git push -u origin main || git push -u origin master || { echo "Error: Failed to push changes."; exit 1; }

echo "Successfully updated repository: https://github.com/kay-who-codes/$github_repo_name"

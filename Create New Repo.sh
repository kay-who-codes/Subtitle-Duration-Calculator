#!/bin/bash

# Redirect all output to a log file in the same directory as the script
LOG_FILE="$(dirname "$0")/script_log.txt"
exec > >(tee -a "$LOG_FILE") 2>&1

# Enable debugging
set -x

# Script to create (if needed) and push to a GitHub repository using an access token

# Function to check if repository exists on GitHub
repo_exists() {
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $access_token" "https://api.github.com/repos/kay-who-codes/$github_repo_name")
    echo "$code"
}


# Step 1: Ensure we are in a Git repository
echo "Checking if this is a Git repository..."
if [ ! -d ".git" ]; then
    echo "Initializing new Git repository..."
    git init || { echo "Error: Failed to initialize Git repository"; exit 1; }
else
    echo "Existing Git repository found."
fi

# Step 2: Get repository name
echo "Determining repository name..."
local_repo_name=$(basename "$PWD")
github_repo_name=${local_repo_name// /-}

echo "Local repository name: $local_repo_name"
echo "GitHub repository name: $github_repo_name"

# Step 3: Read GitHub access token
echo "Reading GitHub access token..."
access_token_file="A:/Programming/Access Tokens/Github Access Token - Repo.txt"  # Update this path for your system

# Check if the access token file exists
if [ ! -f "$access_token_file" ]; then
    echo "Error: Access token file not found at $access_token_file"
    echo "Please ensure the path to the access token file is correct."
    exit 1
fi

# Read the access token and remove any trailing newlines
access_token=$(tr -d '\n' < "$access_token_file")
echo "Access token read successfully."

# Step 4: Check/Create GitHub repository
echo "Checking if repository exists on GitHub..."
response_code=$(repo_exists)

if [ "$response_code" = "404" ]; then
    echo "Repository does not exist. Creating new repository on GitHub..."
    curl_output=$(curl -H "Authorization: token $access_token" -H "Accept: application/vnd.github.v3+json" \
        -d "{\"name\":\"$github_repo_name\", \"private\":false}" \
        https://api.github.com/user/repos 2>&1)
    curl_exit_code=$?

    if [ "$curl_exit_code" -ne 0 ]; then
        echo "Error: Failed to create repository. Curl output:"
        echo "$curl_output"
        exit 1
    else
        echo "Repository created successfully."
    fi
elif [ "$response_code" = "200" ]; then
    echo "Repository already exists on GitHub."
else
    echo "Error: Unexpected response code from GitHub API: $response_code"
    echo "Please check your access token and repository name."
    exit 1
fi

# Step 5: Configure Git remote
echo "Configuring Git remote..."
git remote remove origin 2> /dev/null
git remote add origin "https://$access_token@github.com/kay-who-codes/$github_repo_name.git"
if [ $? -ne 0 ]; then
    echo "Error: Failed to set remote URL."
    exit 1
else
    echo "Git remote configured successfully."
fi

# Step 6: Stage changes
echo "Staging changes..."
git add -A
if [ $? -ne 0 ]; then
    echo "Error: Failed to stage changes."
    exit 1
else
    echo "Changes staged successfully."
fi

# Step 7: Commit
echo "Creating commit..."
commit_msg="Update repository with latest changes"
echo "Enter commit message (leave blank for default):"
read -r user_commit_msg

[ -n "$user_commit_msg" ] && commit_msg="$user_commit_msg"

git commit -m "$commit_msg"
if [ $? -ne 0 ]; then
    echo "Error: Failed to commit changes."
    exit 1
else
    echo "Changes committed successfully."
fi

# Step 8: Push changes
echo "Pushing to GitHub..."
git push -u origin main || git push -u origin master
if [ $? -ne 0 ]; then
    echo "Error: Failed to push changes. Check if your main branch exists."
    exit 1
else
    echo "Changes pushed successfully."
fi

echo "Successfully updated repository: https://github.com/kay-who-codes/$github_repo_name"
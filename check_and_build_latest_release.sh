#!/usr/bin/env bash

# This script checks if there is a new release of the project and if so, cleans and builds it.

# Define the root directory
ROOT_DIR=$(pwd)
echo "Root directory: $ROOT_DIR"

# Check if there is a new release
GITHUB_REPO="MediaBrowser/Emby.SDK"
GITHUB_RELEASES_URL="https://api.github.com/repos/$GITHUB_REPO/releases"

# Get the release tag for the first entry in the releases
LATEST_RELEASE_TAG=$(curl -s $GITHUB_RELEASES_URL | jq -r '.[0].tag_name')
LATEST_RELEASE_TAG_LOWER=$(echo $LATEST_RELEASE_TAG | tr '[:upper:]' '[:lower:]')

# Read the last known release tag from latest_release.txt
LAST_KNOWN_RELEASE_TAG=$(cat latest_release.txt)

# Note last run time
date > last_run.txt

# If the latest release tag is the same as the last known release tag, exit
if [ "$LATEST_RELEASE_TAG" == "$LAST_KNOWN_RELEASE_TAG" ]; then
    echo "No new release found."
    exit 1
fi

echo "New release found: $LATEST_RELEASE_TAG"

# If there is a new release, update the last known release tag
echo "$LATEST_RELEASE_TAG" > latest_release.txt

# Delete the Emby.SDK directory if it exists
rm -rf Emby.SDK || true

# Clone the repository
echo "Cloning the repository..."
GITHUB_REPO_URL="https://github.com/$GITHUB_REPO.git"
git clone $GITHUB_REPO_URL || true

# Change to the Python project directory
cd Emby.SDK/SampleCode/RestApi/Clients/Python || exit 1

# If the new version contains "beta" in the tag, switch to the beta branch
if [[ $LATEST_RELEASE_TAG_LOWER == *"beta"* ]]; then
    echo "Switching to the beta branch..."
    git checkout beta
fi

### Everything below this is now in the Python project directory

## Fix the bad stuff done by this dumb OpenAPI auto-generated code
echo "Fixing the bad stuff..."

# Replace "embyclient-python" with "embyclient" in every file in the directory
find . -type f -exec sed -i 's/embyclient-python/embyclient/g' {} + || true

# Replace any folder with "embyclient-python" in the name with "embyclient"
find . -type d -name "*embyclient-python*" -exec bash -c 'mv "$0" "${0/embyclient-python/embyclient}"' {} \; || true

# Replace README.md with a better one
cp "$ROOT_DIR"/better_readme.md better_readme.md
mv better_readme.md README.md

# Replace "setup.py" with a better one
# Copy the better setup.py to the project directory
cp "$ROOT_DIR"/better_setup.py better_setup.py
# Find VERSION in setup.py and replace 'PORTVERSION' in better_setup.py with the value
VERSION=$(grep -o "VERSION = \".*\"" setup.py)
sed -i "s/# PORTVERSION/$VERSION/g" better_setup.py
# Find REQUIRES in setup.py and replace 'PORTREQUIRES' in better_setup.py with the value
REQUIRES=$(grep -o "REQUIRES = \[.*\]" setup.py)
sed -i "s/# PORTREQUIRES/$REQUIRES/g" better_setup.py
# Replace setup.py with better_setup.py
mv better_setup.py setup.py

# Install necessary Python packages for building and releasing the project on PyPi
echo "Installing necessary Python packages..."
pip install --upgrade setuptools wheel twine

# Build the project
echo "Building the project..."
python setup.py sdist bdist_wheel



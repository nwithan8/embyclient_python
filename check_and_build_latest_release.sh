#!/usr/bin/env bash

# This script checks if there is a new release of the project and if so, cleans and builds it.

# Optionally define the root
ROOT_DIR=${1:-'~'}

# Check if there is a new release
GITHUB_REPO="MediaBrowser/Emby.SDK"
GITHUB_RELEASES_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

# Get the latest release tag
LATEST_RELEASE_TAG=$(curl -s $GITHUB_RELEASES_URL | jq -r '.tag_name')

# Read the last known release tag from latest_release.txt
LAST_KNOWN_RELEASE_TAG=$(cat latest_release.txt)

# If the latest release tag is the same as the last known release tag, exit
if [ "$LATEST_RELEASE_TAG" == "$LAST_KNOWN_RELEASE_TAG" ]; then
    echo "No new release found."
    date > last_run.txt
    exit 0
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

### Everything below this is now in the Python project directory

## Fix the bad stuff done by this dumb OpenAPI auto-generated code
echo "Fixing the bad stuff..."

# Replace "embyclient-python" with "embyclient" in every file in the directory
find . -type f -exec sed -i 's/embyclient-python/embyclient/g' {} +

# Replace any folder with "embyclient-python" in the name with "embyclient"
find . -type d -name "*embyclient-python*" -exec bash -c 'mv "$0" "${0/embyclient-python/embyclient}"' {} \;

# Delete "ReadMe.md" and replace it with "README.md"
rm ReadMe.md && cp "$ROOT_DIR"/better_readme.md README.md

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

# Note last run time
date > "$ROOT_DIR"/last_run.txt



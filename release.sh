#!/bin/sh

set -o errexit

# Version compare functions
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"; }
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }
 

# Detect git last version
TAG_VERSION=$(git describe --abbrev=0 --tags 2> /dev/null)
if [ -z TAG_VERSION ]; then
    TAG_VERSION="{Tag not found}"
fi

# Increment last version for suggest new version
DEFAULT_NEW_VERSION=""
regex="([0-9]+).([0-9]+).([0-9]+)"
if [[ $TAG_VERSION =~ $regex ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  build="${BASH_REMATCH[3]}"

  DEFAULT_NEW_VERSION="$major.$minor.$((build+1))"
fi

# Get new version
echo "Current version is $TAG_VERSION"
echo "Please write new version : [DEFAULT: $DEFAULT_NEW_VERSION] "
read newVersion

# If new version and default new version is empty exit
if [ -z "$newVersion" ] && [ -z "$DEFAULT_NEW_VERSION" ]; then
    echo "You should set new version for deploy"
    exit 1
fi

# If new version is empty and default version is not empty use default new version
if [ -z "$newVersion" ] && [ ! -z "$DEFAULT_NEW_VERSION" ]; then
    newVersion="$DEFAULT_NEW_VERSION"
fi

# Create new tag and push to git
if version_le $newVersion $TAG_VERSION; then
    echo "New version sould be greater than git version"
    exit 1
fi

echo "Writting new version $newVersion"

git commit --allow-empty -m "Version $newVersion"
git tag -a "$newVersion" -m "Version $newVersion"
git push
git push -u origin "$newVersion"            
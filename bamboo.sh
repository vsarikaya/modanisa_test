#!/bin/sh

set -o errexit

GIT_TAG_VERSION=$(git describe --abbrev=0 --tags 2> /dev/null)
if [ -z "$GIT_TAG_VERSION" ]; then
    echo "You should set new version for deploy (GIT doesnt have any tag)"
    exit 1
fi

EB_VERSION="$(eb status | grep -oP "(?<=Deployed Version: Version )([A-Za-z0-9.]+)(?=$)")"

# Alternative
# aws elasticbeanstalk describe-application-versions --application-name modanisa_external \
# | python -c "import json,sys;obj=json.load(sys.stdin);print obj['ApplicationVersions'][0]['VersionLabel'];" \
# | sed -r "s/Version //" 2>&1

if [ "$GIT_TAG_VERSION" = "$EB_VERSION" ]; then
    echo "No have any new tag"
    exit 1
fi

eb deploy -l "Version $GIT_TAG_VERSION"



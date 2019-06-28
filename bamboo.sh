#!/bin/sh

set -o errexit

EB_APPLICATION_NAME="modanisa_external"
S3_BUCKET="elasticbeanstalk-eu-central-1-142903308389"
S3_BUCKET_FOLDER="$S3_BUCKET/$EB_APPLICATION_NAME"

GIT_TAG_VERSION=$(git describe --abbrev=0 --tags 2> /dev/null)
if [ -z "$GIT_TAG_VERSION" ]; then
    echo "You should set new version for deploy (GIT doesnt have any tag)"
    exit 1
fi

EB_VERSION="$(aws elasticbeanstalk describe-application-versions --application-name $EB_APPLICATION_NAME \
            | python -c "import json,sys;obj=json.load(sys.stdin);print obj['ApplicationVersions'][0]['VersionLabel'];" \
            | sed -r "s/Version //" 2>&1)"


if [ "$GIT_TAG_VERSION" = "$EB_VERSION" ]; then
    echo "No have any new tag"
    exit 1
fi

# Compress all files with git tag
echo "Compressing files for $GIT_TAG_VERSION"
UPLOAD_FILE_NAME="Version ${GIT_TAG_VERSION}.zip"
zip "$UPLOAD_FILE_NAME" -r * .[^.]*

CHECK_EXISTS_S3_FILE=$(aws s3 ls "s3://$S3_BUCKET_FOLDER/$UPLOAD_FILE_NAME" | wc -l)
if [ "$CHECK_EXISTS_S3_FILE" -ne 0 ]; then
    echo "Version already uploaded"
    exit 1
fi

# Uploading S3
echo "Uploading to S3 Bucket"
aws s3 cp "$UPLOAD_FILE_NAME" "s3://$S3_BUCKET_FOLDER/"

# Install new version to ElasticBeanstalk
echo "aws elasticbeanstalk create-application-version --application-name $EB_APPLICATION_NAME --version-label $UPLOAD_FILE_NAME --source-bundle S3Bucket=$S3_BUCKET,S3Key=$EB_APPLICATION_NAME/$UPLOAD_FILE_NAME"
aws elasticbeanstalk create-application-version --application-name "$EB_APPLICATION_NAME" --version-label "$UPLOAD_FILE_NAME" --source-bundle S3Bucket="$S3_BUCKET",S3Key="$EB_APPLICATION_NAME/$UPLOAD_FILE_NAME"

#!/bin/sh

filePath=".elasticbeanstalk/version.config"

touch $filePath && source $filePath

if [ -z "$Version" ]; then
    echo "Version=1.0.0" >> $filePath
    source $filePath 
fi    

echo "Current version is $Version"
echo "Please write new version : "
read newVersion


if [ "$Version" = "$newVersion" ]; then
    echo "Same version not need deployment"
else
    echo "Writting new version $newVersion"
    sed -i -e "s/$Version/$newVersion/g" "$filePath" 2>&1

    git tag -a "$newVersion" -m "Version $newVersion"
    git push origin "$newVersion"
fi
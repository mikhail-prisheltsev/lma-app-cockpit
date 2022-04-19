#!/bin/bash
source `dirname $0`/config.sh

execute() {
  $@ || exit
}

if [ -z "$secrets.DEV_HUB_URL" ]; then
  echo "set default devhub user"
  execute sfdx force:config:set defaultdevhubusername=$DEV_HUB_ALIAS
fi

## uncomment for the First time (creation the package)
# echo "Create new unlocked package"
# execute sfdx force:package:create --name $PACKAGE_NAME --packagetype Unlocked --path force-app --nonamespace --targetdevhubusername $DEV_HUB_ALIAS --json

# echo "Unlocked package created"

echo "Create new package version.."
echo "Running: sfdx force:package:version:create -p $PACKAGE_NAME -x -w 10 --codecoverage -v $DEV_HUB_ALIAS --json"

VERSION_DATA="$(execute sfdx force:package:version:create -p $PACKAGE_NAME -x -w 10 --codecoverage -v $DEV_HUB_ALIAS --json)"
echo $VERSION_DATA
PACKAGE_VERSION="$(echo $VERSION_DATA | jq '.result.SubscriberPackageVersionId' | tr -d '"')"

echo "Package version created: $PACKAGE_VERSION"

# echo "Promote with: sfdx force:package:version:promote -p $PACKAGE_VERSION -v $DEV_HUB_ALIAS"
echo "Install from: /packaging/installPackage.apexp?p0=$PACKAGE_VERSION"

echo "Promoting the package.."
sfdx force:package:version:promote -p $PACKAGE_VERSION -v $DEV_HUB_ALIAS
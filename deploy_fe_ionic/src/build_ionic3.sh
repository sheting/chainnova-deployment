#!/bin/sh

#env=${ENV:-'prod'}
mode="--prod"
echo "### Building env:$mode start. ###"

# sh ./images/login.sh
# if [ $? != 0 ]; then
#   exit 1
# fi

NODE_ENV=development npm i
# yarn build$mode
ionic cordova build browser $mode --minifyjs --minifycss
ls -l | grep -q -E "\s+www$"
if [[ $? != 0 ]]; then
  echo "!!!ERR: Failed to build!"
  exit 1
fi

echo "*** SUCCESS ***"
exit 0
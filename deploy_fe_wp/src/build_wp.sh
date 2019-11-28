#!/bin/sh

env=${ENV:-'preview'}
mode=" --mode $env"
echo "### Building mode:$mode start. ###"

# sh ./images/login.sh
# if [ $? != 0 ]; then
#   exit 1
# fi

NODE_ENV=development yarn
yarn build$mode
ls -l | grep -q -E "\s+dist$"
if [[ $? != 0 ]]; then
  echo "!!!ERR: Failed to build!"
  exit 1
fi

echo "*** SUCCESS ***"
exit 0
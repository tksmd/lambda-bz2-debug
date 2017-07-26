#!/bin/bash
#
# Script to create deployment package
#
# http://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html
# https://serverlesscode.com/post/scikitlearn-with-amazon-linux-container/
#
BuildDir=$(mktemp -d build-XXXXXX)
trap "rm -fr ${BuildDir}" 3 9 15

PackageName="lambda-bz2-debug.zip"

###
### Functions
###
function build_package()
{
  cp *.py ${BuildDir}
  if [ -d ./venv/lib64/python3.6/site-packages/ ]; then
    cp -pr venv/lib64/python3.6/site-packages/* ${BuildDir}
  fi

  mkdir -p ${BuildDir}/lib
  [ -d /usr/lib64/atlas ] && cp -p /usr/lib64/atlas/* ${BuildDir}/lib
  for l in "/usr/lib64/libquadmath.so.0" "/usr/lib64/libgfortran.so.3"
  do
    [ -f ${l} ] && cp -p $l ${BuildDir}/lib/
  done

  find ${BuildDir} -type d -name "__pycache__" | xargs rm -fr
  find ${BuildDir} -type f -name "*.pyc" | xargs rm -fr
  find ${BuildDir} -type f -name "*.so" | xargs strip

  pushd .
  cd ${BuildDir} ; zip -9 -r lambda-bz2-debug . ; mv lambda-bz2-debug.zip ../${PackageName}
  popd
  rm -fr ${BuildDir}
}

###
### Main
###
build_package

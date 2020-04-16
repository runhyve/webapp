#!/bin/sh
set -ex

if [ $(id -u) -ne 0 ]; then
  echo "This script requires root permission because creates iocage jail to build Runhyve webapp."
  exit 2
fi

export JAILER_TAG="webapp-${CI_COMMIT_REF_NAME}"
./tools/jailer build .

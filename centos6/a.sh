#!/bin/sh

error_exit() {
  echo $1
  exit 1
}

: &&
./fail.sh &&
: || error_exit 'failed'
echo 'all ok'
exit 0

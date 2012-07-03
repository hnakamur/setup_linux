#!/bin/bash
if [ $# -lt 2 ]; then
  cat <<EOF
Usage: $0 guest_ip hostname [configfile]
EOF
  exit 1
fi

connect=$1
hostname=$2
conf=${3:-post_init.conf}

cat - $conf post_init.sh <<EOF | ssh root@$connect
hostname=$hostname
EOF

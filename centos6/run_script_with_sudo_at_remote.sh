#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 host scriptpath [args...]" 1>&2
  exit 1
fi

host=$1
scriptpath=$2

# rest args
# NOTE: There is a limitation that we cannot have spaces in arguments.
shift 2

scriptfile=`basename $scriptpath`
cat $scriptpath | ssh $host '
file="/tmp/'"$scriptfile"'.$$" &&
cat > "$file" &&
chmod +x "$file" &&
sudo "$file" $@ &&
rm "$file"'

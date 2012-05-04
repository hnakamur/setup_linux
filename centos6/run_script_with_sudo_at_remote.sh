#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 host scriptfile [args...]" 1>&2
  exit 1
fi

host=$1
scriptfile=$2

# rest args
# NOTE: There is a limitation that we cannot have spaces in arguments.
shift 2

cat $scriptfile | ssh $host "
file=/tmp/$scriptfile.\$$ &&
cat > \$file &&
chmod +x \$file &&
sudo \$file $@ &&
rm \$file"

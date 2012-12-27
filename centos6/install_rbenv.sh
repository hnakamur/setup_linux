#!/bin/bash

version=1.9.3-p327

yum -y install git gcc make libxslt-devel libxml2-devel \
  gdbm-devel libffi-devel zlib-devel openssl-devel libyaml-devel \
  readline-devel curl-devel openssl-devel pcre-devel memcached-devel \
  valgrind-devel mysql-devel

git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv
mkdir /usr/local/rbenv/{shims,versions}

git clone git://github.com/sstephenson/ruby-build.git /usr/local/ruby-build
cd /usr/local/ruby-build
./install.sh

cat >> /usr/local/rbenv/bashrc <<'EOF'
export RBENV_ROOT=/usr/local/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"
EOF

cat >> /root/.bashrc <<'EOF'

. /usr/local/rbenv/bashrc
EOF

. /usr/local/rbenv/bashrc

# yaml will be installed by rbenv install
rbenv install $version
rbenv global $version

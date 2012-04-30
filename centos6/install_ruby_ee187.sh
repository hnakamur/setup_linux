#!/bin/sh
sudo yum install -y gcc-c++ patch make readline-devel zlib-devel \
  libyaml-devel libffi-devel openssl-devel curl-devel git
cd /usr/local/src
sudo curl -LO http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-1.8.7-2011.03.tar.gz
sudo tar zxf ruby-enterprise-1.8.7-2011.03.tar.gz
sudo ruby-enterprise-1.8.7-2011.03/installer --dont-install-useful-gems --no-dev-docs -a /usr/local

sudo cat >>/root/.gemrc <<EOF
install: --no-ri --no-rdoc
update: --no-ri --no-rdoc
EOF

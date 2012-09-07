#!/bin/sh

rubygems_version=1.8.24

# install ruby and packages for building gems on CentOS 6.x
yum install -y ruby ruby-devel ruby-ri ruby-rdoc ruby-shadow gcc gcc-c++ automake autoconf make curl dmidecode

cd /tmp
curl -O http://production.cf.rubygems.org/rubygems/rubygems-${rubygems_version}.tgz
tar zxf rubygems-${rubygems_version}.tgz
cd rubygems-${rubygems_version}
ruby setup.rb --no-format-executable

#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 (ruby1.9|ruby1.8ee|ruby1.8)" 1>&2
  exit 1
fi

install_epel() {
  if [ ! -f /etc/yum.repos.d/epel.repo ]; then
    rpm -ivh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/`uname -p`/epel-release-6-6.noarch.rpm
  fi
}

get_ruby19_version() {
  if which ruby > /dev/null 2>&1; then
    ruby -v | awk '{sub("p","-p",$2);print $2}'
  else
    echo not_installed
  fi
}

install_ruby19() {
  ruby_version=1.9.3-p194 &&
  if [ `get_ruby19_version` != $ruby_version ]; then
    install_epel &&
    yum -y install gcc make libxslt-devel libyaml-devel libxml2-devel \
      gdbm-devel libffi-devel zlib-devel openssl-devel libyaml-devel \
      readline-devel curl-devel openssl-devel pcre-devel memcached-devel \
      valgrind-devel mysql-devel \
    rpm-build rpmdevtools ncurses-devel tcl-devel db4-devel byacc &&
    rpmdev-setuptree &&
    cd ~/rpmbuild/SOURCES &&
    wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz &&
    cd ~/rpmbuild/SPECS &&
    wget https://raw.github.com/imeyer/ruby-1.9.3-rpm/master/ruby19.spec &&
    rpmbuild -bb ruby19.spec &&
    ARCH=`uname -m` &&
    KERNEL_REL=`uname -r` &&
    KERNEL_TMP=${KERNEL_REL%.$ARCH} &&
    DISTRIB=${KERNEL_TMP##*.} &&
    rpm -Uvh ~/rpmbuild/RPMS/${ARCH}/ruby-1.9.3p194-1.${DISTRIB}.${ARCH}.rpm
  fi
}

get_ruby18ee_version() {
  if which ruby > /dev/null 2>&1; then
    ruby -v | awk '{print $2"-"$15}'
  else
    echo not_installed
  fi
}

install_ruby18ee() {
  version=1.8.7-2012.02 &&
  if [ `get_ruby18ee_version` != $version ]; then
    yum -y install gcc-c++ patch make readline-devel zlib-devel \
      libyaml-devel libffi-devel openssl-devel curl-devel git &&
    cd /usr/local/src &&
    curl -LO http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-${version}.tar.gz &&
    tar xf ruby-enterprise-${version}.tar.gz &&
    ruby-enterprise-${version}/installer --dont-install-useful-gems --no-dev-docs -a /usr/local
  fi
}

install_ruby18() {
  yum -y install ruby rubygems ruby-devel make gcc
}

create_gemrc() {
  if [ ! -f /root/.gemrc ]; then
    cat > /root/.gemrc <<EOF
install: --no-rdoc --no-ri 
update:  --no-rdoc --no-ri
EOF
  fi
}

install_chef_solo() {
  if [ -f /etc/chef/solo.rb ]; then
    return 0
  fi &&
  gem install chef knife-solo &&
  mkdir /root/.chef &&
  cat > /root/.chef/knife.rb <<EOF
# .chef/knife.rb
# SEE: http://wiki.opscode.com/display/chef/Troubleshooting+and+Technical+FAQ
# set some sensible defaults
current_dir = File.dirname(__FILE__)
user        = ENV['OPSCODE_USER'] || ENV['USER']

log_level                :debug
log_location             STDOUT
node_name                \`hostname\`
client_key               ''
validation_client_name   ''
validation_key           "#{current_dir}/validation.pem"
chef_server_url          ''
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            "/etc/chef/site-cookbooks" 
cookbook_copyright       'Hiroaki Nakamura'
cookbook_license         'mit'
cookbook_email           'hnakamur@gmail.com'
environment_path         "#{current_dir}/../environments"
EOF
  knife kitchen /etc/chef &&
  mkdir -p /var/log/chef/old &&
  cat > /etc/logrotate.d/nginx <<EOF &&
/var/log/chef/*.log {
    daily
    missingok
    rotate 90
    compress
    delaycompress
    notifempty
    sharedscripts
    dateext
    olddir /var/log/chef/old/
}
EOF
  mkdir /var/chef-solo &&
  cat > /etc/chef/solo.rb <<EOF
file_cache_path '/var/chef-solo'
cookbook_path   '/etc/chef/site-cookbooks'
json_attribs    '/root/node.json'
node_name       \`hostname\`.chomp
log_location    '/var/log/chef/solo.log'
EOF
}

error_exit() {
  echo $1 1>&2
  exit 1
}

case $1 in
ruby1.9)
  export PATH=/usr/local/bin:$PATH &&
  install_ruby19
  ;;
ruby1.8ee)
  export PATH=/usr/local/bin:$PATH &&
  install_ruby18ee
  ;;
ruby1.8)
  install_ruby18
  ;;
esac &&
create_gemrc &&
install_chef_solo || error_exit 'failed'
echo 'Done!'
exit 0

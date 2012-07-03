#!/bin/bash

install_epel() {
  if [ ! -f /etc/yum.repos.d/epel.repo ]; then
    rpm -ivh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/`uname -p`/epel-release-6-7.noarch.rpm
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
      valgrind-devel mysql-devel &&
    cd /usr/local/src &&
    curl -LO http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-${ruby_version}.tar.gz &&
    tar xf ruby-${ruby_version}.tar.gz &&
    cd ruby-${ruby_version} &&
    ./configure &&
    make &&
    make install
  fi
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
  cat > /etc/logrotate.d/chef <<EOF &&
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

export PATH=/usr/local/bin:$PATH &&
install_ruby19 &&
create_gemrc &&
install_chef_solo &&
echo 'Done!'
exit 0

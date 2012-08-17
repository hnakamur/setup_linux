#!/bin/bash

cookbook_copyright='Hiroaki Nakamura'
cookbook_license=mit
cookbook_email=hnakamur@gmail.com

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
  if [ -f /usr/local/rbenv/shims/ruby ]; then
    # hard link
    ln /usr/local/rbenv/shims/ruby /usr/local/rbenv/shims/knife
  fi &&
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
cookbook_path            "/etc/chef/cookbooks" 
cookbook_copyright       '$cookbook_copyright'
cookbook_license         '$cookbook_license'
cookbook_email           '$cookbook_email'
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
cookbook_path   '/etc/chef/cookbooks'
json_attribs    '/root/node.json'
node_name       \`hostname\`.chomp
log_location    '/var/log/chef/solo.log'
log_debug       :debug
EOF
}

create_gemrc &&
install_chef_solo

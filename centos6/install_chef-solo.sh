#!/bin/sh
yum install -y ruby rubygems ruby-devel make gcc

cat > /root/.gemrc <<EOF
install: --no-rdoc --no-ri 
update:  --no-rdoc --no-ri
EOF

gem install chef knife-solo

knife kitchen /etc/chef
cat > /etc/chef/solo.rb <<EOF
file_cache_path '/tmp/chef-solo'
cookbook_path   '/etc/chef/site-cookbooks'
node_name       \`hostname\`.chomp
log_location    '/var/log/chef/solo.log'
EOF

mkdir -p /var/log/chef/old
cat > /etc/logrotate.d/nginx <<EOF
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

mkdir /root/.chef
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

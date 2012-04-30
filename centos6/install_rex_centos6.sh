#!/bin/sh

rpm --import http://rex.linux-files.org/RPM-GPG-KEY-REXIFY-REPO.CENTOS6

cat >/etc/yum.repos.d/rex.repo <<EOF
[rex]
name=Fedora \$releasever - \$basearch - Rex Repository
baseurl=http://rex.linux-files.org/CentOS/6/rex/\$basearch/
enabled=1
EOF

yum install -y rex

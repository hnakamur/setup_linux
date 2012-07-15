#!/bin/bash
perlbrew_root=/usr/local/perlbrew
version=5.16.0

export PERLBREW_ROOT=${perlbrew_root} &&
curl -kL http://install.perlbrew.pl | bash &&
cat >> /root/.bashrc <<EOF &&

export PERLBREW_ROOT=${perlbrew_root}
source ${perlbrew_root}/etc/bashrc
EOF
. /root/.bashrc &&
perlbrew init &&
perlbrew install perl-${version} --as #{version} &&
perlbrew switch ${version} &&
perlbrew install-cpanm &&
cpanm --self-upgrade &&
cat <<EOF
==============================================================================
Run "source /root/.bashrc" manually to use perl installed by perlbrew
==============================================================================
EOF

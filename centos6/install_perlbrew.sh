#!/bin/bash
perlbrew_root=/usr/local/perlbrew
perlbrew_home=/usr/local/perlbrew/etc
version=5.16.1

export PERLBREW_ROOT=${perlbrew_root} &&
curl -kL http://install.perlbrew.pl | bash &&
cat >> /root/.bash_profile <<EOF &&

export PERLBREW_HOME=${perlbrew_home}
source ${perlbrew_root}/etc/bashrc
EOF
export PERLBREW_HOME=${perlbrew_home} &&
source ${perlbrew_root}/etc/bashrc &&
perlbrew init &&
perlbrew install perl-${version} &&
perlbrew switch ${version} &&
perlbrew install-cpanm &&
cpanm --self-upgrade &&
cat <<EOF
==============================================================================
Re-login or run "source /root/.bash_profile" manually to enable perlbrew.
==============================================================================
EOF

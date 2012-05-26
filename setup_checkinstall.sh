#!/bin/bash
if [ $UID -ne 0 ]; then
  echo Please run as root $0
  exit 1
fi

basearch=`uname -p`
srcbasedir=/usr/local/src
downloaddir=$srcbasedir

checkinstall_version=1.6.2
checkinstall_local_srcpkg=checkinstall-$checkinstall_version.tar.gz
checkinstall_download_url=http://asic-linux.com.mx/~izto/checkinstall/files/source/$checkinstall_local_srcpkg
checkinstall_local_rpm=/usr/src/redhat/RPMS/$basearch/checkinstall-$checkinstall_version-1.$basearch.rpm

checkinstall_srcpkg_downloaded() {
  test -f $downloaddir/$checkinstall_local_srcpkg
}

download_checkinstall_srcpkg() {
  cd $downloaddir && curl -O $checkinstall_download_url
}

setup_checkinstall_srcpkg() {
  checkinstall_srcpkg_downloaded || download_checkinstall_srcpkg
}

checkinstall_rpm_built() {
  test -f $checkinstall_local_rpm
}

build_checkinstall_rpm() {
  setup_checkinstall_srcpkg &&
  yum install -y gettext rpm-build gcc make &&
  cd $srcbasedir &&
  tar xf $downloaddir/checkinstall-$checkinstall_version.tar.gz &&
  cd checkinstall-${checkinstall_version} &&
  make &&
  make install &&
  if [ $basearch = x86_64 -a ! -f /usr/local/lib64/installwatch.so ]; then
    ln -s /usr/local/lib/installwatch.so /usr/local/lib64/installwatch.so
  fi &&
  /usr/local/sbin/checkinstall -y -R --nodoc \
    --pkgsource=$checkinstall_download_url
}

build_checkinstall() {
  checkinstall_rpm_built || build_checkinstall_rpm
}

checkinstall_rpm_installed() {
  rpm -q --quiet checkinstall > /dev/null 2>&1
}

install_checkinstall_rpm() {
  rpm -ivh $checkinstall_local_rpm
}

setup_checkinstall_rpm() {
  checkinstall_rpm_installed || build_checkinstall && install_checkinstall_rpm
}

setup_checkinstall_rpm

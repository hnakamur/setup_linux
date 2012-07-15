
# This script must be run by run_post_init.sh

# operations
add_admin_user() {
  groupadd -g $gid $group &&
  useradd -g $group -u $uid $login &&
  mkdir /home/$login/.ssh &&
  chmod 700 /home/$login/.ssh &&
  echo $pubkey > /home/$login/.ssh/authorized_keys &&
  chmod 600 /home/$login/.ssh/authorized_keys &&
  chown -R $login:$group /home/$login/.ssh &&
  cat >> /etc/sudoers <<EOF

# $login configs
Defaults:$login !requiretty
Defaults:$login secure_path = /usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
$login ALL=(ALL) NOPASSWD: ALL
EOF
}

modify_sshd_configs() {
  sed -i.orig -e '
s/^PasswordAuthentication yes/PasswordAuthentication no/
/^UsePAM yes/d
/^#PermitRootLogin yes/a\
PermitRootLogin no
/^X11Forwarding yes/d
' /etc/ssh/sshd_config &&
  /etc/init.d/sshd reload
}

install_common_rpms() {
  yum install -y \
    bind-utils \
    file \
    git \
    mailx \
    man \
    ntp \
    openssh-clients \
    patch \
    rsync \
    screen \
    sysstat \
    traceroute \
    vim-enhanced
}

setup_ntp() {
  ntpd -gq &&
  /etc/init.d/ntpd start &&
  chkconfig ntpd on
}

setup_hostname() {
  sed -i -e 's/^HOSTNAME=.*/HOSTNAME='$hostname'/' /etc/sysconfig/network
}

# main
set -x &&
add_admin_user &&
modify_sshd_configs &&
install_common_rpms &&
setup_ntp &&
setup_hostname &&
yum -y update &&
reboot

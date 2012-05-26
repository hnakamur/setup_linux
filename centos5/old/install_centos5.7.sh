#!/bin/bash

if [ $# -ne 2 ]; then
  echo Usage $0 hostname ipaddress
  exit 1
fi

hostname=$1
ipaddress=$2

# Common configs
releasever=5.7
basearch=x86_64
netmask=255.255.255.0
gateway=192.168.11.1 
nameserver=192.168.11.1
#location_url=http://ftp.riken.jp/Linux/centos/$releasever/os/$basearch/
#location_url=http://ftp.kddilabs.jp/Linux/packages/CentOS/6.2/os/x86_64/
location_url=http://vault.centos.org/$releasever/os/$basearch/
# NOTE: You can use /sbin/grub-md-crypt to get encrypted password.
root_encrypted_pw='$1$AvrTd0$NNXNpu5JYHNNG6JMnRSI7/'
user_encrypted_pw='$1$xyuTd0$XVWYOPm2bdQzlpulmYDqM1'
user_loginid=hnakamur
user_pubkey='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAokqmX07JuL5EhDr9EHR6jhNKV0Im5l8Wv/F343NJs1X4qoKtvcixTTyl+BLNtczOLUbyzqVpCOjWIs2hDwYyrounFVw/+TM2abp4pFUgB6qnDY7T+8kSKw3mSAIjDt4rZIkuizzRonGsTkjw8hBT5OokUSR68xVcwaphdcu8ZvHp8/Um5+6eay4D1S0pDOEvf6FEhADDr1c10IPGwsCOpLcxSHCkVFOkZzmgSTSt/7BlX90278oyDOjIKEqisSwi0HaHWvsJ1C3WUtDFVpR85+rH70mt5UH2DbPfZ9W2to+Pgh7nNg95CO6H0geH1tWejS0yQ4ZE0EOKYuFaiPdMVQ== hnakamur@sunshine103'

disk_path=/var/kvm/images/${hostname}.img
disk_size=20
ram_size=1024
vcpus=2

ksfile=/tmp/$hostname-ks.cfg.$$
ksfdimg=/tmp/$hostname-ks.img.$$

make_ksfile() {
  cat <<KSFILE_EOF > $ksfile
install
url --url=${location_url}
lang en_US.UTF-8
keyboard us
#network --onboot yes --device eth0 --bootproto dhcp --noipv6
network --device eth0 --bootproto static --ip ${ipaddress} --netmask ${netmask} --gateway ${gateway} --nameserver ${nameserver} --hostname ${hostname}
rootpw --iscrypted $root_encrypted_pw
firewall --enabled --port=22:tcp
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc Asia/Tokyo
bootloader --location=mbr --driveorder=vda --append="console=ttyS0,115200n8"

clearpart --all --initlabel --drives=vda
part /boot --fstype=ext3 --size=100
part pv.0 --grow --size=1
volgroup VolGroup pv.0
logvol swap --name=lv_swap --vgname=VolGroup --grow --size=1008 --maxsize=2016
logvol / --fstype=ext3 --name=lv_root --vgname=VolGroup --grow --size=1024 --maxsize=51200

repo --name="CentOS"  --baseurl=${location_url}
user --name=${user_loginid} --password=$user_encrypted_pw --iscrypted --uid=500
reboot

%packages --nobase
@core
bind-utils
man
sudo
sysstat
traceroute
vim-enhanced
wget
which

%post --log=/root/kickstart-post.log

mkdir /home/${user_loginid}/.ssh &&
chmod 700 /home/${user_loginid}/.ssh &&
cat <<KEY_EOF > /home/${user_loginid}/.ssh/authorized_keys &&
$user_pubkey
KEY_EOF
chmod 600 /home/${user_loginid}/.ssh/authorized_keys &&
chown -R ${user_loginid}:${user_loginid} /home/${user_loginid}/.ssh &&

echo "export VIMINIT='set sw=2 ts=2 et'" \
  >> /home/${user_loginid}/.bash_profile &&

cat >> /etc/sudoers <<SUDOERS_EOF &&
# Per-user configs
Defaults:${user_loginid} !requiretty
Defaults:${user_loginid} secure_path = /usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
Defaults:${user_loginid} env_keep += "VIMINIT"
${user_loginid} ALL=(ALL) NOPASSWD: ALL
SUDOERS_EOF

sed -i.orig -e '
s/^mirrorlist=/#&/
s/^#\(baseurl=http:\/\/\)mirror\.centos\.org\/centos\/\$releasever\(.*\)/\1vault.centos.org\/'$releasever'\2/
' /etc/yum.repos.d/CentOS-Base.repo &&
yum update -y
KSFILE_EOF
}

make_ksfdimg() {
  workdir=/tmp/makeksfd.$$ &&
  dd if=/dev/zero of=$ksfdimg bs=1440K count=1 > /dev/null 2>&1 &&
  /sbin/mkfs -F -t ext2 $ksfdimg > /dev/null 2>&1 &&
  mkdir $workdir &&
  sudo mount -o loop $ksfdimg $workdir &&
  cp -p $ksfile $workdir/ks.cfg &&
  sudo umount $workdir &&
  rm -rf $workdir
}


run_virt_install() {
  sudo virt-install -n ${hostname} \
  -r ${ram_size} \
  --disk path=${disk_path},size=${disk_size},device=disk,bus=virtio,format=raw \
  --disk path=$ksfdimg,device=floppy \
  --vcpus=${vcpus} \
  --os-type=linux \
  --os-variant=rhel6 \
  --network=bridge=br0,model=virtio \
  --nographics \
  --extra-args='console=ttyS0,115200n8 ks=floppy' \
  --location=$location_url

# Cannot use --cdrom option.
#  --cdrom=CentOS-6.2-x86_64-minimal.iso \
#ERROR    --extra-args only work if specified with --location.
#ERROR    Only one install method can be used (--location URL, --cdrom CD/ISO, --pxe, --import, --boot hd|cdrom|...)
}

make_ksfile &&
make_ksfdimg &&
run_virt_install &&
rm $ksfile $ksfdimg

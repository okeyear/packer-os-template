# RHEL 9 kickstart file for Vagrant boxes

# Use CDROM installation media
cdrom
repo --name="BaseOS" --baseurl=file:///run/install/sources/mount-0000-cdrom/BaseOS
repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream
# repo --name="BaseOS" --baseurl=file:///run/install/repo/BaseOS
# repo --name="AppStream" --baseurl=file:///run/install/repo/AppStream
# url --url https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/kickstart/
# repo --name=BaseOS --baseurl=https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/
# repo --name=AppStream --baseurl=https://repo.almalinux.org/almalinux/9/AppStream/x86_64/os/

text
skipx
eula --agreed
# Run the Setup Agent on first boot
firstboot --disabled

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
# lang zh_CN
lang en_US.UTF-8
# System timezone
timezone Asia/Shanghai --utc
# timesource --ntp-disable

# Network information
# network  --bootproto=static --device=ens192 --gateway=192.168.168.1 --ip=192.168.168.10 --netmask=255.255.255.0 --ipv6=auto --activate
network --bootproto=dhcp --ipv6=auto --activate
network --hostname=template9

firewall --disabled --ssh
services --enabled=sshd,rsyslog,sshd,NetworkManager
selinux --disabled
# selinux --enforcing

bootloader --append=" net.ifnames=0 biosdevname=0 crashkernel=no" # --location=mbr
# bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"



######### disk partation
# Generated using Blivet version 3.4.0
ignoredisk --only-use=sda
# Partition clearing information
clearpart --none --initlabel

######### 1. auto part
#### 1. auto part
# Clear the Master Boot Record
# zerombr
# Remove partitions
# clearpart --all --initlabel
# Automatically create partitions using LVM
# autopart --type=lvm

######### disk partation, 2. manual create , must include 1M biosboot partation
#### 2. refer almalinux: https://github.com/AlmaLinux/cloud-images
%pre --log=/root/pre_log # --erroronfail
/usr/bin/dd bs=512 count=10 if=/dev/zero of=/dev/sda
/usr/sbin/parted -s -a optimal /dev/sda -- mklabel gpt
# /usr/sbin/parted -s -a optimal /dev/sda -- mkpart biosboot 1MiB 2MiB set 1 bios_grub on
# /usr/sbin/parted -s -a optimal /dev/sda -- mkpart '"EFI System Partition"' fat32 2MiB 202MiB set 2 esp on
# /usr/sbin/parted -s -a optimal /dev/sda -- mkpart boot xfs 202MiB 1226MiB
# /usr/sbin/parted -s -a optimal /dev/sda -- mkpart root xfs 1226MiB 100%
/usr/sbin/parted --script /dev/sda print 
/usr/bin/sleep  30
%end 

# Disk partitioning information
part biosboot --fstype=biosboot --ondisk=sda --label=biosboot --size=1 #  --recommended  # 
part /boot/efi --fstype="efi" --ondisk=sda --size=200 --fsoptions="umask=0077,shortname=winnt" 
part /boot --fstype="xfs" --ondisk=sda --size=1024
# pvcreate
part pv.01 --fstype="lvmpv" --ondisk=sda --size=1 --grow
# vgcreate
volgroup vg pv.01 # --pesize=4096
# lvcreate
# logvol swap --vgname=vg --name=lv_swap --size=4096 # --recommended # --ondisk=sda
logvol / --fstype="xfs" --name=lv_root --vgname=vg --size=1 --grow


rootpw vagrant
user --name=vagrant --plaintext --password vagrant
# Reboot after successful installation
reboot --eject


%packages --inst-langs=en
@core
@^minimal-environment
@development
cloud-init
%end
# -open-vm-tools


# disable kdump service
%addon com_redhat_kdump --disable
%end

# %addon com_redhat_oscap
# content-type = scap-security-guide
# profile = xccdf_org.ssgproject.content_profile_pci-dss
# %end

# %post --erroronfail
%post
# grub2-install --target=i386-pc /dev/sda
# grub2-mkconfig -o /boot/grub2/grub.cfg
# allow vagrant user to run everything without a password
echo "vagrant     ALL=(ALL)     NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
# see Vagrant documentation (https://docs.vagrantup.com/v2/boxes/base.html)
# for details about the requiretty.
sed -i "s/^.*requiretty/# Defaults requiretty/" /etc/sudoers
yum clean all
# permit root login via SSH with password authetication
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/01-permitrootlogin.conf
# vagrant user ssh-keypair
rm -Rf /home/vagrant/.ssh
mkdir /home/vagrant/.ssh
# wget -O /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
# wget -O /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' | tee /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys
%end

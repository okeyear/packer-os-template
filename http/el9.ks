# RHEL 9 kickstart file for Vagrant boxes

cdrom
# url --url https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/kickstart/
# repo --name=BaseOS --baseurl=https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/
# repo --name=AppStream --baseurl=https://repo.almalinux.org/almalinux/9/AppStream/x86_64/os/

text
skipx
eula --agreed
firstboot --disabled

# lang zh_CN
lang en_US.UTF-8
keyboard --vckeymap=us --xlayouts='us'
timezone Asia/Shanghai

network --bootproto=dhcp --ipv6=auto --activate
network --hostname=template9

firewall --disabled --ssh
services --enabled=sshd
selinux --disabled
# selinux --enforcing

bootloader --location=mbr --append=" net.ifnames=0 biosdevname=0 crashkernel=no"
# bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"

# Clear the Master Boot Record
zerombr
# Remove partitions
clearpart --all --initlabel
# Automatically create partitions using LVM
autopart --type=lvm

# %pre --erroronfail
# parted -s -a optimal /dev/sda -- mklabel gpt
# parted -s -a optimal /dev/sda -- mkpart biosboot 1MiB 2MiB set 1 bios_grub on
# parted -s -a optimal /dev/sda -- mkpart '"EFI System Partition"' fat32 2MiB 202MiB set 2 esp on
# parted -s -a optimal /dev/sda -- mkpart boot xfs 202MiB 1226MiB
# parted -s -a optimal /dev/sda -- mkpart root xfs 1226MiB 100%
# %end
# 
# part biosboot --fstype=biosboot --onpart=sda1
# part /boot/efi --fstype=efi --onpart=sda2
# part /boot --fstype=xfs --onpart=sda3
# part / --fstype=xfs --onpart=sda4


rootpw vagrant
user --name=vagrant --plaintext --password vagrant
# Reboot after successful installation
reboot --eject

# -open-vm-tools

%packages --inst-langs=en
@core
@^minimal-environment
kexec-tools
bzip2
dracut-config-generic
grub2-pc
tar
usermode
-biosdevname
-dnf-plugin-spacewalk
-dracut-config-rescue
-iprutils
-iwl*-firmware
-langpacks-*
-mdadm
-plymouth
-rhn*
%end


# disable kdump service
%addon com_redhat_kdump --disable
%end


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
%end
# RHEL 9 kickstart file for Vagrant boxes
install
cdrom
# url --url https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/kickstart/
# repo --name=BaseOS --baseurl=https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/
# repo --name=AppStream --baseurl=https://repo.almalinux.org/almalinux/9/AppStream/x86_64/os/

text
skipx
eula --agreed
firstboot --disabled

lang zh_CN
keyboard --xlayouts='us'
timezone Asia/Shanghai

network --bootproto=dhcp
firewall --disabled --ssh
services --enabled=sshd
selinux --enforcing

bootloader --location=mbr
# bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"

%pre --erroronfail
# parted -s -a optimal /dev/sda -- mklabel gpt
# parted -s -a optimal /dev/sda -- mkpart biosboot 1MiB 2MiB set 1 bios_grub on
# parted -s -a optimal /dev/sda -- mkpart '"EFI System Partition"' fat32 2MiB 202MiB set 2 esp on
# parted -s -a optimal /dev/sda -- mkpart boot xfs 202MiB 1226MiB
# parted -s -a optimal /dev/sda -- mkpart root xfs 1226MiB 100%
%end

# part biosboot --fstype=biosboot --onpart=sda1
# part /boot/efi --fstype=efi --onpart=sda2
# part /boot --fstype=xfs --onpart=sda3
# part / --fstype=xfs --onpart=sda4
# part pv.01 --size=1 --grow
# volgroup vg pv.01
# logvol swap --vgname=vg --name=lv_swap --size=4096 # --recommended # --ondisk=sda
# logvol / --vgname=vg --name=lv_root --fstype xfs --size=1 --grow

# disk part 1: /boot 1G /boot/efi 200M
part /boot --fstype ext4 --size=1024
part /boot/efi --fstype ext4 --size=200
# disk part 2: swap 4G
part pv.01 --size=1 --grow
volgroup vg pv.01
logvol swap --vgname=vg --name=lv_swap --size=4096 # --recommended # --ondisk=sda
# logvol /tmp --vgname=vg --name=lv_tmp --fstype ext4 --size=2048
# disk part 3: / 15G
logvol / --vgname=vg --name=lv_root --fstype ext4 --size=1 --grow


rootpw vagrant
user --name=vagrant --plaintext --password vagrant

reboot --eject


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
-open-vm-tools
-plymouth
-rhn*
%end


# disable kdump service
%addon com_redhat_kdump --disable
%end


%post --erroronfail
grub2-install --target=i386-pc /dev/sda
# allow vagrant user to run everything without a password
echo "vagrant     ALL=(ALL)     NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
# see Vagrant documentation (https://docs.vagrantup.com/v2/boxes/base.html)
# for details about the requiretty.
sed -i "s/^.*requiretty/# Defaults requiretty/" /etc/sudoers
yum clean all
# permit root login via SSH with password authetication
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/01-permitrootlogin.conf
%end
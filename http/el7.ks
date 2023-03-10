#version=RHEL7
# Install OS instead of upgrade
install
# 文本安装 graphical为图形化安装
text  
# Local Install
cdrom 
# Network Install
# url --url=http://10.10.10.100/linux/
# System language
lang en_US.UTF-8 --addsupport=zh_CN.UTF-8
# Keyboard layouts
keyboard us # --vckeymap=us --xlayouts='us'
unsupported_hardware

# Firewall configuration
firewall --disabled
# firewall --eanble --ssh
# SELinux configuration
selinux --disabled  
# System timezone
timezone Asia/Shanghai
# Do not configure the X Window System
skipx
# Accept license: End User License Agreement，EULA
eula --agreed       # 同意最终用户许可协议
# Run the Setup Agent on first boot
firstboot --disable # 关闭第一次启动后的安装配置
ignoredisk --only-use=sda   # 默认第一块启动盘

# Network information
network  --bootproto=dhcp --hostname os-template --onboot=on

# Disk partitioning information
clearpart --all --initlabel
# Clear the Master Boot Record
zerombr
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda

# autopart --type=lvm
# disk part 1: /boot 1G
part /boot --fstype ext4 --size=1024
# disk part 2: swap 4G
part pv.01 --size=1 --grow
volgroup vg pv.01
logvol swap --vgname=vg --name=lv_swap --size=4096 # --recommended # --ondisk=sda
# logvol /tmp --vgname=vg --name=lv_tmp --fstype ext4 --size=2048
# disk part 3: / 15G
logvol / --vgname=vg --name=lv_root --fstype ext4 --size=1 --grow

# System authorization information
auth --enableshadow --passalgo=sha512 --kickstart
# Root password  --iscrypted
rootpw vagrant
user --name=vagrant --plaintext --password vagrant --groups=vagrant,wheel --shell=/bin/bash --homedir=/home/vagrant
# group --name=admin

# config yum repo
# repo --name=repoid [--baseurl=<url>|--mirrorlist=url] [options]
# repo --name=base --baseurl=http://mirror.centos.org/centos/7/os/x86_64/

# System services
# services --enabled="chronyd"
services --enabled=NetworkManager,sshd,chronyd
# 服务之间用逗号隔开，不能有空格
services --disabled autid,cups,smartd,nfslock  

# Reboot after installation
reboot  # 安装后重启

# %include /usr/share/anaconda/interactive-defaults.ks


# 系统安装前所执行的脚本
# %pre
# %end

# 安装包开始
# %packages块指定以下都是需要进行安装的包。最小化安装需要@base和@core。@后写的是包组    
%packages --ignoremissing --excludedocs
@base
@core
@Development Tools
# @chinese-support
vim
wget
curl
%end
# 安装包结束

# post 系统安装后所执行的脚本, 可以指定解释器比如python
%post # --interpreter=/bin/bash
# yum update -y
groupadd admin
echo "%admin         ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
/bin/echo 'UseDNS no' >> /etc/ssh/sshd_config
yum clean all

/bin/mkdir /home/vagrant/.ssh
/bin/chmod 700 /home/vagrant/.ssh
/bin/echo -e 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' > /home/vagrant/.ssh/authorized_keys
/bin/chown -R vagrant:vagrant /home/vagrant/.ssh
/bin/chmod 0400 /home/vagrant/.ssh/*
%end # post end

# kdump kernel crash dumping
%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

# password policy pwpolicy
# %anaconda
# pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
# pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
# pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
# %end


################ pending: org_fedora_oscap
# Resolution
# Change the openscap addon section of the kickstart to reflect one of the profiles that is available on the binary DVD. The following openscap profiles are available:
# standard
# pci-dss
# C2S
# rht-ccp
# common
# stig-rhel7-disa
# stig-rhevh-upstream
# ospp-rhel7
# cjis-rhel7-server
# docker-host
# nist-800-171-cui
# The following is an example of a valid openscap kickstart addon section that you can use for reference:

# Raw
%addon org_fedora_oscap
    content-type = scap-security-guide
    profile = stig-rhel7-disa
%end
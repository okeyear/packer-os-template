#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# export LANG=en
set -e
# stty erase ^H
# refer to https://github.com/AlmaLinux/cloud-images/blob/master/ansible/roles/cleanup_vm/tasks/main.yml

# Remove old kernels
sudo dnf remove -y $(dnf repoquery --installonly --latest-limit=-1 -q)
# Delete DNF cache
sudo dnf clean all

# temporary files
sudo rm -rf /tmp/* /var/tmp/*

# SSH host keys
sudo rm -f /etc/ssh/*host*key*


# Remove kickstart files
# sudo rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

# Truncate files
sudo truncate -s 0  /etc/machine-id
sudo truncate -s 0  /etc/resolv.conf
sudo truncate -s 0  /var/log/audit/audit.log
sudo truncate -s 0  /var/log/wtmp
sudo truncate -s 0  /var/log/lastlog
sudo truncate -s 0  /var/log/btmp
sudo truncate -s 0  /var/log/cron
sudo truncate -s 0  /var/log/maillog
sudo truncate -s 0  /var/log/messages
sudo truncate -s 0  /var/log/secure
sudo truncate -s 0  /var/log/spooler

# Remove log folders.
sudo rm -rf /var/log/anaconda/*
sudo rm -rf /var/log/qemu-ga/*
sudo rm -rf /var/log/tuned/*
sudo rm -rf /var/lib/cloud/*
sudo rm -rf /etc/hostname/*
sudo rm -rf /etc/machine-info/*
sudo rm -rf /var/lib/systemd/credential.secret/*

# log files.
sudo rm -rf /var/log/{*log,*.old,*.log.gz,*.[0-9],*.gz,*-????????}
sudo rm -rf /var/log/sssd/{*log,*.old,*.log.gz,*.[0-9],*.gz,*-????????}

# Remove random-seed
sudo rm -rf /var/lib/systemd/random-seed

# Disable root SSH login via password
# sudo rm -f /etc/ssh/sshd_config.d/01-permitrootlogin.conf

# Fill free space with zeroes
# dd if=/dev/zero of=/zeroed_file bs=1M oflag=direct || rm -f /zeroed_file

# Wipe out swap data
# grep -oP '^/dev/[\w-]+' /proc/swaps
#  block:
#    - name: Get swap partition UUID
#      command: "blkid {{ swaps.stdout }} -s UUID -o value"
#      register: swap_blkid
#
#    - name: Unmount swap partition
#      command: "swapoff {{ swaps.stdout }}"
#
#    - name: Fill swap partition with zeroes
#      shell: "dd if=/dev/zero of={{ swaps.stdout }} bs=1M oflag=direct || /bin/true"
#
#    - name: Format swap partition
#      command: "mkswap -U {{ swap_blkid.stdout }} -f {{ swaps.stdout }}"
#
#    - name: Mount swap partition
#      command: "swapon {{ swaps.stdout }}"
#  when: swaps.rc == 0

# Sync disc
sync

# Clear shell history
history -c

# Check if WALinuxAgent is installed (Azure), Deprovision WALinuxAgent
[ -f /usr/sbin/waagent ] && waagent -deprovision+user -force
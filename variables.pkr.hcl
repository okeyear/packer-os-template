variables {
  //
  // common variables
  //
  iso_url_8_x86_64       = "https://repo.almalinux.org/almalinux/8.7/isos/x86_64/AlmaLinux-8.7-x86_64-boot.iso"
  iso_checksum_8_x86_64  = "file:https://repo.almalinux.org/almalinux/8.7/isos/x86_64/CHECKSUM"
  iso_url_9_x86_64       = "file://D:/ISO/rhel-baseos-9.1-x86_64-dvd.iso"
  iso_checksum_9_x86_64  = "D9DCAE2B6E760D0F9DCF4A517BDDC227D5FA3F213A8323592F4A07A05AA542A2"
  headless               = true
  boot_wait              = "10s"
  cpus                   = 2
  memory                 = 2048
  post_cpus              = 1
  post_memory            = 1024
  http_directory         = "http"
  ssh_timeout            = "3600s"
  root_shutdown_command  = "/sbin/shutdown -hP now"
  qemu_binary            = ""
  ovmf_code              = "/usr/share/OVMF/OVMF_CODE.secboot.fd"
  ovmf_vars              = "/usr/share/OVMF/OVMF_VARS.secboot.fd"
  aavmf_code             = "/usr/share/AAVMF/AAVMF_CODE.fd"
  vnc_bind_address       = "127.0.0.1"
  vnc_port_min           = 5900
  vnc_port_max           = 6000

  //
  // Hyper-V specific variables
  //
  hyperv_switch_name = ""

  //
  // Vagrant specific variables
  //
  vagrant_boot_command_8_x86_64 = [
    "<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el8.vagrant.ks<enter><wait>"
  ]

  # LABEL=RHEL-8-7-0-BaseOS-x86_64
  vagrant_boot_command_8_x86_64_uefi = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-8-7-x86_64-dvd ro ",
    "inst.text biosdevname=0 net.ifnames=0 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el8.vagrant.ks<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
  ]
  vagrant_boot_command_9_x86_64 = [
    "<tab> inst.text inst.gpt inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el9.vagrant.ks<enter><wait>"
  ]
  vagrant_boot_command_9_x86_64_uefi = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-9-1-x86_64-dvd ro ",
    "inst.text biosdevname=0 net.ifnames=0 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el9.vagrant.ks<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
  ]
  vagrant_disk_size        = 20000
  vagrant_shutdown_command = "echo vagrant | sudo -S /sbin/shutdown -hP now"
  vagrant_ssh_username     = "vagrant"
  vagrant_ssh_password     = "vagrant"
}
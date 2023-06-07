
variable "os_ver" {
  description = "RHEL Based OS version"

  type    = string
  default = "9.1"

  validation {
    condition     = can(regex("[5-9].[0-9]$|[5-9].[1-9][0-9]$", var.os_ver))
    error_message = "The os_ver value must be one of released or prereleased versions of RHEL Based OS."
  }
}

locals {
  os_ver_major = split(".", var.os_ver)[0]
  os_ver_minor = split(".", var.os_ver)[1]
}

variables {
  //
  // common variables
  //
  iso_url_8_x86_64       = "https://repo.almalinux.org/almalinux/8.7/isos/x86_64/AlmaLinux-8.7-x86_64-boot.iso"
  iso_checksum_8_x86_64  = "file:https://repo.almalinux.org/almalinux/8.7/isos/x86_64/CHECKSUM"
  iso_url_9_x86_64       = "file://D:/ISO/rhel-baseos-${var.os_ver}-x86_64-dvd.iso"
  iso_checksum_9_x86_64  = "D9DCAE2B6E760D0F9DCF4A517BDDC227D5FA3F213A8323592F4A07A05AA542A2"
  headless               = false
  boot_wait              = "10s"
  cpus                   = 2
  memory                 = 2048
  post_cpus              = 1
  post_memory            = 1024
  http_directory         = "http"
  ssh_timeout            = "3600s"
  root_shutdown_command  = "/sbin/shutdown -hP now"
  vnc_bind_address       = "127.0.0.1"
  vnc_port_min           = 5900
  vnc_port_max           = 6000

  //
  // Hyper-V specific variables
  //
  # need external switch, for example , br-wifi， br-eth
  hyperv_switch_name = "br-wifi"

  //
  // Vagrant specific variables
  //
  # rhel iso label: RHEL-9-1-0-BaseOS-x86_64
  # alma iso label: AlmaLinux-8-7-x86_64-dvd AlmaLinux-9-1-x86_64-dvd "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-8-7-x86_64-dvd ro ",
  # rocky iso label:
  vagrant_boot_command_8_x86_64 = [
    "<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el8.ks<enter><wait>"
  ]

  # LABEL=RHEL-8-7-0-BaseOS-x86_64
  vagrant_boot_command_8_x86_64_uefi = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-8-${local.os_ver_minor}-x86_64-dvd ro ",
    "inst.text biosdevname=0 net.ifnames=0 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el8.ks<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
  ]
  vagrant_boot_command_9_x86_64 = [
    "<tab> inst.text inst.gpt inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el9.ks<enter><wait>"
  ]
  vagrant_boot_command_9_x86_64_uefi = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=RHEL-9-${local.os_ver_minor}-0-BaseOS-x86_64-dvd ro ",
    "inst.text biosdevname=0 net.ifnames=0 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el9.ks<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
  ]
  # Upload to Azure, need fixed size , not dynamic size, we only need 8G to install OS
  vagrant_disk_size        = 8192
  vagrant_shutdown_command = "echo vagrant | sudo -S /sbin/shutdown -hP now"
  vagrant_ssh_username     = "vagrant"
  vagrant_ssh_password     = "vagrant"
}

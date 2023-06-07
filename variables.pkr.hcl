### variables
# local中可以使用已有变量和表达式expression
# variable variables中不可以用已有变量和表达式expression

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

locals {
  iso_url_9_x86_64       = "file://D:/ISO/rhel-baseos-${var.os_ver}-x86_64-dvd.iso"
  iso_checksum_9_x86_64  = "D9DCAE2B6E760D0F9DCF4A517BDDC227D5FA3F213A8323592F4A07A05AA542A2"
}


# common variables

variable "headless" {
  description = "Disable GUI"

  type    = bool
  default = false
}

variable "boot_wait" {
  description = "Time to wait before typing boot command"

  type    = string
  default = "10s"
}

variable "cpus" {
  description = "The number of virtual cpus"

  type    = number
  default = 2
}

variable "memory" {
  description = "The amount of memory"

  type    = number
  default = 2048
}

variable "post_cpus" {
  description = "The number of virtual cpus after the build"

  type    = number
  default = 1
}

variable "post_memory" {
  description = "The number of virtual cpus after the build"

  type    = number
  default = 1024
}

variable "http_directory" {
  description = "Path to a directory to serve kickstart files"

  type    = string
  default = "http"
}

variable "ssh_timeout" {
  description = "The time to wait for SSH to become available"

  type    = string
  default = "3600s"
}

variable "root_shutdown_command" {
  description = "The command to use to gracefully shut down the machine"

  type    = string
  default = "/sbin/shutdown -hP now"
}

# Vagrant variables

variable "vagrant_disk_size" {
  # Upload to Azure Cloud, need fixed size , not dynamic size; reduce disk sizeGB to 8G
  description = "The size in MiB of hard disk of VM"

  type    = number
  default = 8192
}

variable "vagrant_shutdown_command" {
  description = "The command to use to gracefully shut down the machine"

  type    = string
  default = "echo vagrant | sudo -S /sbin/shutdown -hP now"
}

variable "vagrant_ssh_username" {
  description = "The username to connect to SSH with"

  type    = string
  default = "vagrant"
}

variable "vagrant_ssh_password" {
  description = "A plaintext password to use to authenticate with SSH"

  type    = string
  default = "vagrant"
}


local "vagrant_boot_command_9_x86_64_uefi" {
  # rhel iso label: RHEL-9-1-0-BaseOS-x86_64 LABEL=RHEL-8-7-0-BaseOS-x86_64
  # alma iso label: AlmaLinux-8-7-x86_64-dvd AlmaLinux-9-1-x86_64-dvd "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-8-7-x86_64-dvd ro ",
  # rocky iso label:
  expression = [
    "c",
    "<wait>",
    "linuxefi /images/pxeboot/vmlinuz",
    " inst.stage2=hd:LABEL=RHEL-9-${local.os_ver_minor}-0-BaseOS-x86_64-dvd ro",
    " inst.text biosdevname=0 net.ifnames=0",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel9.ks",
    "<enter>",
    "initrdefi /images/pxeboot/initrd.img",
    "<enter>",
    "boot<enter><wait>"
  ]
}

variable "vagrant_boot_command_9_x86_64_bios" {
  description = "Boot command for x86_64 BIOS"

  type = list(string)
  default = [
    "<tab>",
    "inst.text inst.gpt inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel9.ks",
    "<enter><wait>"
  ]
}


# Hyper-V variables

variable "hyperv_switch_name" {
  description = "The name of the switch to connect the virtual machine to"
  # need external switch, for example : br, br-wifi， br-eth
  # hyperv_switch_name = "br-wifi"
  type    = string
  default = null
}

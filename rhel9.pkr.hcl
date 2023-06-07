/*
 * Packer build OS template for AlmaLinux/CentOS/RockyLinux/RHEL
 * Also for Vagrant boxes
 */
 
### part I. source
source "hyperv-iso" "rhel9" {
  iso_url               = local.iso_url_9_x86_64
  iso_checksum          = local.iso_checksum_9_x86_64
  boot_command          = local.vagrant_boot_command_9_x86_64_uefi
  boot_wait             = var.boot_wait
  generation            = 2
  switch_name           = var.hyperv_switch_name
  cpus                  = var.cpus
  memory                = var.memory
  enable_dynamic_memory = true
  disk_size             = var.vagrant_disk_size
  disk_block_size       = 1
  headless              = var.headless
  http_directory        = var.http_directory
  shutdown_command      = var.vagrant_shutdown_command
  communicator          = "ssh"
  ssh_username          = var.vagrant_ssh_username
  ssh_password          = var.vagrant_ssh_password
  ssh_timeout           = var.ssh_timeout
}


source "virtualbox-iso" "rhel9" {
  iso_url              = local.iso_url_9_x86_64
  iso_checksum         = local.iso_checksum_9_x86_64
  boot_command         = local.vagrant_boot_command_9_x86_64_uefi
  boot_wait            = var.boot_wait
  cpus                 = var.cpus
  memory               = var.memory
  disk_size            = var.vagrant_disk_size
  headless             = var.headless
  http_directory       = var.http_directory
  guest_os_type        = "RedHat_64"
  shutdown_command     = var.vagrant_shutdown_command
  ssh_username         = var.vagrant_ssh_username
  ssh_password         = var.vagrant_ssh_password
  ssh_timeout          = var.ssh_timeout
  hard_drive_interface = "sata"
  vboxmanage_post = [
    ["modifyvm", "{{.Name}}", "--memory", var.post_memory],
    ["modifyvm", "{{.Name}}", "--cpus", var.post_cpus]
  ]
}


source "vmware-iso" "rhel9" {
  iso_url          = local.iso_url_9_x86_64
  iso_checksum     = local.iso_checksum_9_x86_64
  boot_command     = local.vagrant_boot_command_9_x86_64_uefi
  boot_wait        = var.boot_wait
  cpus             = var.cpus
  memory           = var.memory
  disk_size        = var.vagrant_disk_size
  headless         = var.headless
  http_directory   = var.http_directory
  guest_os_type    = "centos-64"
  shutdown_command = var.vagrant_shutdown_command
  ssh_username     = var.vagrant_ssh_username
  ssh_password     = var.vagrant_ssh_password
  ssh_timeout      = var.ssh_timeout
  vmx_data = {
    "cpuid.coresPerSocket" : "1"
  }
  vmx_data_post = {
    "memsize" : var.post_memory
    "numvcpus" : var.post_cpus
  }

  vmx_remove_ethernet_interfaces = true
}


### part II. build

build {
  sources = [
    # "sources.hyperv-iso.rhel9"
    # "sources.virtualbox-iso.rhel9"
    "sources.vmware-iso.rhel9"
  ]

  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "sudo rm -fr /etc/ssh/*host*key*"
    ]
    # only = [
    #   "hyperv-iso.rhel9"
    # ]
  }

  # provisioner "ansible" {
  #   user             = "vagrant"
  #   use_proxy        = false
  #   playbook_file    = "./ansible/vagrant-box.yml"
  #   galaxy_file      = "./ansible/requirements.yml"
  #   roles_path       = "./ansible/roles"
  #   collections_path = "./ansible/collections"
  #   ansible_env_vars = [
  #     "ANSIBLE_PIPELINING=True",
  #     "ANSIBLE_REMOTE_TEMP=/tmp",
  #     "ANSIBLE_SSH_ARGS='-o ControlMaster=no -o ControlPersist=180s -o ServerAliveInterval=120s -o TCPKeepAlive=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
  #   ]
  #   extra_arguments = [
  #     "--extra-vars",
  #     "packer_provider=${source.type} ansible_ssh_pass=vagrant"
  #   ]
  #   only = [
  #     "hyperv-iso.almalinux-9"
  #   ]
  # }

  post-processors {

    # post-processor "vagrant" {
    #   compression_level = "9"
    #   output            = "AlmaLinux-9-Vagrant-9.1-${formatdate("YYYYMMDD", timestamp())}.x86_64.{{.Provider}}.box"
    #   except = [
    #     "qemu.almalinux-9",
    #     "vmware-iso.almalinux-9-aarch64",
    #     "parallels-iso.almalinux-9-aarch64"
    #   ]
    # }

    post-processor "shell-local" {
      scripts = fileset(".", "shell/{sshd,cleanup}.sh")
    }
    post-processor "shell-local" {
      scripts = fileset(".", "shell/azurevm_el8.sh")
      only = [
        "hyperv-iso.rhel9"
      ]
    }
  }
}


### part III. variables

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

# Vagrant

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
  # rhel iso label: RHEL-9-1-0-BaseOS-x86_64
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


# Hyper-V

variable "hyperv_switch_name" {
  description = "The name of the switch to connect the virtual machine to"
  # need external switch, for example : br, br-wifi， br-eth
  # hyperv_switch_name = "br-wifi"
  type    = string
  default = null
}

/*
 * AlmaLinux/CentOS/RockyLinux/RHEL 9 Packer template for building Vagrant boxes.
 */

source "hyperv-iso" "el9" {
  iso_url               = var.iso_url_9_x86_64
  iso_checksum          = var.iso_checksum_9_x86_64
  boot_command          = var.vagrant_boot_command_9_x86_64_uefi
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


source "virtualbox-iso" "el9" {
  iso_url              = var.iso_url_9_x86_64
  iso_checksum         = var.iso_checksum_9_x86_64
  boot_command          = var.vagrant_boot_command_9_x86_64
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


source "vmware-iso" "el9" {
  iso_url          = var.iso_url_9_x86_64
  iso_checksum     = var.iso_checksum_9_x86_64
  boot_command          = var.vagrant_boot_command_9_x86_64
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



build {
  sources = [
    "sources.hyperv-iso.el9"
    # "sources.virtualbox-iso.el9"
    # "sources.vmware-iso.el9"
  ]

  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "sudo rm -fr /etc/ssh/*host*key*"
    ]
    only = [
      "hyperv-iso.el9"
    ]
  }
}
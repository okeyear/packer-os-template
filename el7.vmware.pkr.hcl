# build rhel/centos/rocky/almalinux os template
# https://developer.hashicorp.com/packer/plugins/builders/vmware/iso
# required:
# - packer: https://developer.hashicorp.com/packer/docs
# - open firewall port 8000-9000 if use "http_directory"
# How to start ?
# Command: packer build el7.vmware.pkr.hcl


variable "hardware_version" {
  type        = string
  description = "The vmx hardware_version: https://kb.vmware.com/s/article/1003746."
  default = "15"
}

variable "iso_url" {
  type        = string
  description = "The ISO file."
  # default = "file://D:/ISO/Linux/rhel-server-7.9-x86_64-dvd.iso"
  default = "https://mirrors.aliyun.com/centos/7/isos/x86_64/CentOS-7-x86_64-Everything-2207-02.iso?spm=a2c6h.25603864.0.0.74092d1cBNle2S"
}

variable "iso_checksum" {
  type        = string
  description = "The ISO checksum file."
  # default = "19D653CE2F04F202E79773A0CBEDA82070E7527557E814EBBCE658773FBE8191"
  default = "f3f83472a24c8ebc66c81b346a743f4000b6b6ddf8c0eb098422d41476873b3b"
}

source "vmware-iso" "vmware-iso" {
  boot_command        = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/el7.ks.cfg <enter><wait>"]
  boot_wait           = "10s"
  cpus                = 1
  memory              = 1024
  disk_size           = 20480
  format              = "ova"
  guest_os_type       = "rhel7-64"
  http_directory      = "http"
  iso_checksum        = var.iso_checksum
  iso_url             = var.iso_url
  shutdown_command    = "echo 'vagrant'|sudo -S /sbin/halt -h -p"
  ssh_password        = "vagrant"
  ssh_port            = 22
  ssh_username        = "vagrant"
  ssh_wait_timeout    = "10000s"
  tools_upload_flavor = "linux"
  version             = var.hardware_version
  vm_name             = "packer-rhel7-os-template"
}

build {
  sources = ["source.vmware-iso.vmware-iso"]
  # post-processors {
  #   post-processor "shell-local" {
  #     scripts = fileset(".", "scripts/{sshd,cleanup}.sh")
  #   }
  # }
}



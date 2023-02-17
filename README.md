# packer-os-template
build rhel/centos/rocky/almalinux os template

- Packer Docs: https://developer.hashicorp.com/packer/plugins/builders/vmware/iso

## required
- packer: https://developer.hashicorp.com/packer/docs
- open firewall port 8000-9000 if use "http_directory"
```shell
netsh advfirewall firewall  add rule name="Allow packer http ports" dir=in action=allow protocol=TCP localport="8000-9000"
```
- privide: hyper-v,vmware,virtualbox,qemu,vsphere,cloud(...)

## TODO
规范化的写法，参考 https://github.com/AlmaLinux/cloud-images

## How to start ?
Command: 
```shell
# step 1
# git clone this repo
# step 2
# modify variables
# step 3
packer build el7.vmware.pkr.hcl
packer build el9-vagrant.pkr.hcl
```
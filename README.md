# packer-os-template
Build rhel/centos/rocky/almalinux os template via hashicorp packer.
(Used for vagrant or public/private cloud)

## required
- packer: https://developer.hashicorp.com/packer/docs
- open firewall port 8000-9000 if use "http_directory"
```shell
netsh advfirewall firewall  add rule name="Allow packer http ports" dir=in action=allow protocol=TCP localport="8000-9000"
```
- privide: hyper-v,vmware,virtualbox,qemu,vsphere,cloud(...)

## TODO

规范化的写法

参考1 https://github.com/AlmaLinux/cloud-images

参考2 https://github.com/goffinet/packer-kvm

rhel/centos/rocky/almalinux 7/8/9 vmware/vsphere/hyper-v/virtualbox/azure os template

## How to start ?
Command: 
```shell
# step 1
# git clone this repo
# step 2
# modify variables
# step 3
packer build rhel9.pkr.hcl
packer build -only="vmware-iso.rhel9" .
packer build -var hyperv_switch_name="br" -only="hyperv-iso.rhel9" .
packer build -var hyperv_switch_name="br" -only="hyperv-iso.rhel9" rhel9.pkr.hcl
```

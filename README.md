# packer-os-template
build rhel/centos/rocky/almalinux os template

- Packer Docs: https://developer.hashicorp.com/packer/plugins/builders/vmware/iso

## required
- packer: https://developer.hashicorp.com/packer/docs
- open firewall port 8000-9000 if use "http_directory"
- privide: hyper-v,vmware,virtualbox,qemu,vsphere,cloud(...)

## TODO
规范化的写法，参考 https://github.com/AlmaLinux/cloud-images

## How to start ?
Command: 
```shell
packer build el7.vmware.pkr.hcl
```
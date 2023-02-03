# packer-os-template
build rhel/centos/rocky/almalinux os template

- Packer Docs: https://developer.hashicorp.com/packer/plugins/builders/vmware/iso

## required
- packer: https://developer.hashicorp.com/packer/docs
- open firewall port 8000-9000 if use "http_directory"

## How to start ?
Command: 
```shell
packer build el7.vmware.pkr.hcl
```
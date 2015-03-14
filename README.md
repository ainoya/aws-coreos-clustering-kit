CoreOS Clustering Kit
======================

Set-up tools for clustering CoreOS on AWS.

Which cluster this kit orchestrate
--------------------------

This kit is made for purpose to clustering CoreOS like below;

![](https://dl.dropboxusercontent.com/u/10177896/coreos-cluster.png)

For cluster discovery, this kit uses `https://etd.discovery.io` as discovery service.

Prerequisites
-------------

## Tool requirements

- Terraform
- Packer
- jq


Rake Tasks
-----------

- `rake ami`:  make CoreOS ami customized by your-own user-data with packer
- `rake apply`: build coreos cluster with terraform

References
-----------

- [Easy Development/Testing Cluster](https://coreos.com/docs/cluster-management/setup/cluster-architectures/)

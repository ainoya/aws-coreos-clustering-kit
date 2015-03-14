CoreOS Clustering Kit
======================

Set-up tools for clustering CoreOS on AWS.

Prerequisite
-------------

## tool requirements

- Terraform
- Packer
- jq


Rake Tasks
-----------

- `rake ami`:  make CoreOS ami customized by your-own user-data with packer
- `rake apply`: build coreos cluster with terraform


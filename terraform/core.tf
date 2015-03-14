variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ami" { default = "" }

variable "prod" {
    default = {
        sg_ssh = ""
        sg_dev = ""
        sg_intra = ""
        sg_internet = ""
        pub_region_a  = ""
        pub_region_c  = ""
        priv_region_a = ""
        priv_region_c = ""
        docker_registry_domain = ""
        discovery_domain = ""
    }
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "ap-northeast-1"
}

resource "aws_autoscaling_group" "as_coreos_cluster" {
  availability_zones = ["ap-northeast-1c"]
  vpc_zone_identifier = ["${var.prod.priv_region_c}"]

  name = "as_coreos_cluster"
  max_size = 4
  min_size = 4
  health_check_grace_period = 300
  health_check_type = "EC2"
  desired_capacity = 4
  force_delete = true
  load_balancers = [ "${aws_elb.etcd-prod.name}"]
  launch_configuration = "${aws_launch_configuration.as_conf_coreos_cluster.name}"
}

resource "aws_launch_configuration" "as_conf_coreos_cluster" {
    name = "coreos cluster"
    image_id = "${var.ami}"
    instance_type = "m3.medium"
    key_name = "clduser"

    security_groups = ["${var.prod.sg_ssh}", "${var.prod.sg_dev}", "${var.prod.sg_intra}"]
    user_data = "${file("userdata/core-userdata")}"
}

# docker private registry

resource "aws_instance" "data_host" {
    ami = "${var.ami}"
    instance_type = "m3.medium"
    key_name = "clduser"

    tags {
        Name = "Management Containers Host"
        FleetID = "data_host"
    }

    root_block_device {
        device_name = "/dev/xvda"
        volume_type = "gp2" 
        volume_size = "200"
    }

    security_groups = ["${var.prod.sg_ssh}", "${var.prod.sg_dev}", "${var.prod.sg_intra}"]
    subnet_id = "${var.prod.pub_region_c}"

    user_data = "${file("userdata/core-datahost")}"
}

resource "aws_eip" "eip-data-host" {
    instance = "${aws_instance.data_host.id}"
    vpc = true
}

resource "aws_route53_record" "dns-internet-data-host" {
  zone_id = "${var.prod.dns_pub}"
  name = "${var.prod.docker_registry_domain}"
  type = "A"
  ttl = "60"
  records = ["${aws_eip.eip-data-host.public_ip}"]
}

resource "aws_route53_record" "dns-intra-data-host" {
  zone_id = "${var.prod.dns_intra}"
  name = "${var.prod.docker_registry_domain}"
  type = "A"
  ttl = "60"
  records = ["${aws_eip.eip-data-host.private_ip}"]
}

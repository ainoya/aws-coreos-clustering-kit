resource "aws_elb" "etcd-prod" {
    name = "etcd-prod-elb"
    subnets = ["${var.prod.priv_region_a}", "${var.prod.priv_region_c}"]

    security_groups = ["${var.prod.sg_ssh}", "${var.prod.sg_dev}", "${var.prod.sg_intra}"]

    internal = true
    
	listener {
		instance_port = 2379
		instance_protocol = "http"
		lb_port = 80
		lb_protocol = "http"
	}
 
	health_check {
		healthy_threshold = 2
		unhealthy_threshold = 2
		timeout = 5
		target = "HTTP:2379/v2/keys"
		interval = 10
	}
 
    cross_zone_load_balancing=false
}

resource "aws_route53_record" "etcd-prod" {
  zone_id = "${var.prod.dns_intra}"
  name = "${var.prod.discovery_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_elb.etcd-prod.dns_name}"]
}


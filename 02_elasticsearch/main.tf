provider "aws" {
	region = var.region
}


resource "aws_elasticsearch_domain" "server" {
	domain_name = join("", [random_string.domain_name.result, lower(var.project)])
	elasticsearch_version = "7.9"

	cluster_config {
		instance_type = "t3.small.elasticsearch"
	}
    
    
	ebs_options {
		ebs_enabled = "true"
		volume_size = 10
	}

	tags = {
		Name = join("-", [data.aws_caller_identity.current.user_id, var.project])
		Project = var.project
	}
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.server.domain_name

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": "${chomp(data.http.myip.body)}/32"}
            },
            "Resource": "${aws_elasticsearch_domain.server.arn}/*"
        },
	{
            "Effect": "Allow",
            "Principal": {
              "AWS": "*"
            },
            "Action": "es:ESHttpGet",
            "Resource": "${aws_elasticsearch_domain.server.arn}/movies/_search"
	}
    ]
}
POLICIES
}


## We want to allow access to the domain for our own IP address specifically.
data "http" "myip" {
    url = "https://ip.seeip.org/"
}

resource "random_string" "domain_name" {
  length    = 6
  special   = false
  upper     = false
  lower     = true
  number    = false
}

data "aws_caller_identity" "current" {}
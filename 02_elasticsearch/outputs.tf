output "es-domain-url" {
	value = aws_elasticsearch_domain.server.endpoint
}

output "kibana-url" {
	value = aws_elasticsearch_domain.server.kibana_endpoint
}
output "aws_lb_dns_name" {
    value = aws_lb.keycloak_ecs_service.dns_name
}
output "aws_lb_zone_id" {
    value = aws_lb.keycloak_ecs_service.zone_id
}

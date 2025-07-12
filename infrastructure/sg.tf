resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-${var.environment}-app-sg-"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id = aws_security_group.app.id
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.app.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_all_outbound" {
  security_group_id = aws_security_group.app.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
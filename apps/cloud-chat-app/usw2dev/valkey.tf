resource "aws_security_group" "valkey" {
  name        = "${var.app_short_name}-valkey-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id
  description = "Security group for Valkey serverless cache"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_instances.id]
    description     = "Allow access from CCA ECS"
  }
}

resource "aws_elasticache_serverless_cache" "valkey" {
  engine = "valkey"
  name   = "${var.app_short_name}-valkey"

  subnet_ids         = [aws_subnet.cca_private_a.id, aws_subnet.cca_private_b.id]
  security_group_ids = [aws_security_group.valkey.id]

  cache_usage_limits {
    data_storage {
      maximum = 1
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
}

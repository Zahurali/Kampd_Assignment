resource "aws_elasticache_subnet_group" "example" {
  name       = "example-subnet-group"
  subnet_ids = ["private-ap-south-1a", "private-ap-south-1b"]
}

resource "aws_elasticache_parameter_group" "example" {
  name   = "example-parameter-group"
  family = "redis5.0"
  parameter {
    name  = "activerehashing"
    value = "yes"
  }
  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

resource "aws_elasticache_cluster" "example" {
  cluster_id             = "example-cluster"
  engine                 = "redis"
  engine_version         = "5.0.6"
  node_type              = "cache.t3.small"
  num_cache_nodes        = 1
  parameter_group_name   = aws_elasticache_parameter_group.example.name
  subnet_group_name      = aws_elasticache_subnet_group.example.name
  security_group_ids     = [aws_security_group.example.id]
}



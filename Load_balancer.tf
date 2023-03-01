
resource "aws_lb" "Load_balancer" {
  name               = "aws-lb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type = "ipv4"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.public-ap-south-1a.id,aws_subnet.public-ap-south-1b.id]

  
  tags = {
    Name = "Load_balancer"
  }
}

resource "aws_lb_target_group" "webtg" {
  health_check {
    interval =10
    path ="/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2 
  }
  
  name     = "weblb"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.main.id
}

#creating listener
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.Load_balancer.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.webtg.arn
    type = "forward"
  }
}


#attachment

resource "aws_lb_target_group_attachment" "load_esk" {
  target_group_arn = aws_lb_target_group.webtg.arn
  target_id = aws_eks_cluster.demo.id
}




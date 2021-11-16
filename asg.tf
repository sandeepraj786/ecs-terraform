resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-0dd0ccab7e2801812"
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.name
  security_groups      = [aws_security_group.cloudknowledgesg.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "ecs-autoscaling" {
  name                 = "ecs-autoscaling"
  vpc_zone_identifier  = [aws_subnet.public-subnet-1.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 10
  health_check_grace_period = 300
  health_check_type         = "EC2"
}
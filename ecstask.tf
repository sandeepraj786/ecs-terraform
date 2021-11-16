resource "aws_ecs_task_definition" "ecs-task" {
  family = "ecs-task"
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
   # {
   #   name      = ""
   #   image     = "service-second"
   #   cpu       = 10
    #  memory    = 256
    #  essential = true
    #  portMappings = [
    #    {
     #     containerPort = 443
      #    hostPort      = 443
      #  }
     # ]
   # }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-2a, us-east-2b]"
  }
}
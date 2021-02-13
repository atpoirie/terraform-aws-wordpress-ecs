[
  {
    "name": "${ecs_service_container_name}",
    "image": "wordpress:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      },
      {
        "containerPort": 443,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "WORDPRESS_DB_HOST",
        "value": "${wordpress_db_host}"
      },
      {
        "name": "WORDPRESS_DB_USER",
        "value": "${wordpress_db_user}"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD",
        "value": "${wordpress_db_pass}"
      },
      {
        "name": "WORDPRESS_DB_NAME",
        "value": "wordpress"
      }
    ],
    "logConfiguration": { 
      "logDriver": "awslogs",
      "options": { 
        "awslogs-group" : "/ecs/wordpress",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "wordpress"
      }
    }
  }
]

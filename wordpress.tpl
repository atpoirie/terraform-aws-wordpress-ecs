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
    "secrets": [{
      "name": "WORDPRESS_DB_PASSWORD",
      "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:${secret_name}:WORDPRESS_DB_PASSWORD::"
    }],
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
        "name": "WORDPRESS_DB_NAME",
        "value": "wordpress"
      }
    ],
    "logConfiguration": { 
      "logDriver": "awslogs",
      "options": { 
        "awslogs-group" : "/ecs/wordpress",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "wordpress",
        "awslogs-create-group": "true"
      }
    }
  }
]

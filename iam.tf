data "aws_iam_policy_document" "ecs_task_trust" {
   statement {
      effect = "Allow"
      principals {
        type = "Service"
        identifiers = [ "ecs-tasks.amazonaws.com" ]
      }
      actions = [ "sts:AssumeRole" ]
   }
}

data "aws_iam_policy_document" "ecs_task_policy" {
   statement {
     actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:Describe*"
     ]
     effect = "Allow"
     resources = [ "*" ]
   }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "wordpressTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

resource "aws_iam_policy" "ecs_task_policy" {
   name = "wordpressTaskPolicy"
   policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_role_attachment" {
   role = aws_iam_role.ecs_task_role.name
   policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_iam_instance_profile" "ecs_task_profile" {
   name = "wordpressTaskRole"
   role = aws_iam_role.ecs_task_role.name
}
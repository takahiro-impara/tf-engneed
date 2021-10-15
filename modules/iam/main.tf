variable "tagNames" {

}
resource "aws_iam_role" "cloudwatchAgent" {
  name = "cloudwatchAgent"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tagNames
}

resource "aws_iam_role_policy_attachment" "cloudWatchattach" {
  role       = aws_iam_role.cloudwatchAgent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ins_profile" {
  name = "ins_profile"
  role = aws_iam_role.cloudwatchAgent.name
}

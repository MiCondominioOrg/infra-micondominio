resource "aws_iam_role" "glue_role" {
    name = "GlueDataAccessRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Effect = "Allow"
        Principal = {
            Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        }]
    })
}

data "aws_iam_policy_document" "glue_policy_doc" {
    statement {
        actions = [
        "s3:*",
        "glue:*",
        "athena:*"
        ]
        resources = ["*"]
    }
}

resource "aws_iam_policy" "glue_policy" {
    name   = "GlueFullAccessPolicy"
    policy = data.aws_iam_policy_document.glue_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "attach" {
    role       = aws_iam_role.glue_role.name
    policy_arn = aws_iam_policy.glue_policy.arn
}

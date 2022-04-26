resource "aws_kms_key" "this" {
  description = "Key for SecretsManager object structure ${var.kms_key}"
  tags        = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/secretsmanager-${var.kms_key}"
  target_key_id = aws_kms_key.this.id
}

resource "aws_secretsmanager_secret" "this" {
  for_each   = toset(var.secretsmanager_entries)
  name       = "/${var.kms_key}/${each.value}"
  kms_key_id = aws_kms_alias.this.id
}

# IAM roles
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "AWS"
      identifiers = var.accounts
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "secretsmanager-${var.kms_key}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]
    resources = [aws_kms_key.this.arn]
  }

  dynamic "statement" {
    for_each = toset(var.secretsmanager_entries)
    content {
      effect = "Allow"

      actions = [
        "secretsmanager:GetSecretValue",
      ]
      resources = [aws_secretsmanager_secret.this[statement.value].arn]
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "secretsmanager-${var.kms_key}"
  path   = "/"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.id
  policy_arn = aws_iam_policy.this.arn
}

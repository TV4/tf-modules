data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}

module "cluster_autoscaler" {
  source = "../irsa"

  name = "${var.name}-cluster-autoscaler"
  oidc_providers = [
    {
      url = module.eks.cluster_oidc_issuer_url
      arn = module.eks.oidc_provider_arn
    }
  ]
  kubernetes_namespace       = "cluster-autoscaler"
  kubernetes_service_account = "cluster-autoscaler"
  policy_json                = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    sid    = "AllowRoute53Change"
    effect = "Allow"
    actions = [
      "route53:GetChange"
    ]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    sid    = "AllowRoute53Record"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    sid    = "AllowRoute53List"
    effect = "Allow"
    actions = [
      "route53:ListHostedZonesByName"
    ]
    resources = ["*"]
  }
}

module "cert_manager" {
  source = "../irsa"

  name = "${var.name}-cert-manager"
  oidc_providers = [
    {
      url = module.eks.cluster_oidc_issuer_url
      arn = module.eks.oidc_provider_arn
    }
  ]
  kubernetes_namespace       = "cert-manager"
  kubernetes_service_account = "cert-manager"
  policy_json                = data.aws_iam_policy_document.cert_manager.json
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "AllowRoute53Change"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    sid    = "AllowRoute53List"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}

module "external_dns" {
  source = "../irsa"
  name   = "${var.name}-external-dns"
  oidc_providers = [
    {
      url = module.eks.cluster_oidc_issuer_url
      arn = module.eks.oidc_provider_arn
    }
  ]
  kubernetes_namespace       = "external-dns"
  kubernetes_service_account = "external-dns"
  policy_json                = data.aws_iam_policy_document.external_dns.json
}


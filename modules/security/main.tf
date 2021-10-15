variable "tagNames" {

}

variable "env" {

}
data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "this" {
  name                          = var.tagNames["Name"]
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  tags                          = var.tagNames

}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "tf-cloud-trail-${var.env}"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::tf-cloud-trail-${var.env}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::tf-cloud-trail-${var.env}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

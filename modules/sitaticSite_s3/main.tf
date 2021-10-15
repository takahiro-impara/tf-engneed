variable "tagNames" {

}

variable "env" {

}
resource "aws_s3_bucket" "staticSite" {
  bucket = "${var.tagNames["Name"]}-${var.env}"
  acl    = "private"
  tags   = var.tagNames
  versioning {
    enabled = true
  }
}

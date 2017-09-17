terraform {
  backend "s3" {
    bucket = "mleeterraform"
    key    = "blog-martinlee-org/state"
    region = "us-east-1"
  }
}

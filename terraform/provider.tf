provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  alias  = "billing"
  region = "us-east-1"
}
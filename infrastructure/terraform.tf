terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "tomwatsonqa"

    workspaces {
      name = "whatsapp-ai-chatbot"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Project       = "whatsapp-ai-chatbot"
      ProvisionedBy = "terraform"
    }
  }
}

locals {
  project = "whatsapp-ai-chatbot"
}

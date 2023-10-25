terraform {
    required_version = ">= 1.3"
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "< 5.0, >= 4.64"
        }
        google-beta = {
            source  = "hashicorp/google-beta"
            version = "< 5.0, >= 4.64"
        }
    }
}

provider "google" {
    credentials = file("./credentials.json")

    project = var.project_id
    region = var.region
    zone = var.zone
}
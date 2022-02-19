terraform {
  cloud {
    organization = "jszafran"

    workspaces {
      name = "personal-data-lake"
    }
  }
}

variable "os_type" {
  type    = string
  default = "unix" // Assume Unix by default
}
variable "shared_private_link" {
  type = object({
    target_service_id = string
    deploy_shared_private_link = bool
    shared_private_links = list(object({
      groupId = string
      privateLinkResourceId = string
      requestMessage = string
    }))
  })
}

variable "ai_hub_id"{
  type = string
}
variable "ai_hub_outbound_rules" {
  description = "Outbound rules for the AI Hub"
  type = map(object({
    type = string
    destination = object({
      serviceResourceId = string
      subresourceTarget = string
      sparkEnabled = bool
      sparkStatus = string
    })
  }))
  
}

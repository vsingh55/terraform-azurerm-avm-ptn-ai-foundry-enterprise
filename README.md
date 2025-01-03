# terraform-azurerm-avm-ptn-ai-foundry-enterprise

The `avm-ptn-ai-foundry-enterprise` is a comprehensive Terraform module designed to facilitate enterprise-scale AI deployments on Microsoft Azure. As an opinionated module, it addresses critical infrastructure components—including security, networking, AI services, and identity management—providing a robust foundation for Azure AI Foundry initiatives. Azure AI Foundry is a set of capabilities designed to streamline the development and deployment of AI solutions at an enterprise scale. It offers a structured framework to manage the lifecycle of AI models, integrates seamlessly with data services, and leverages the power of Azure's AI and machine learning services.

With Azure AI Foundry, enterprises can accelerate AI solution development and deployment while taking full advantage of Azure AI services like Cognitive Services, Machine Learning, and more. The objective of this module is to deploy an enterprise-ready AI Foundry platform that ensures scalability, security, and operational efficiency. Additionally, it is compatible with Azure Landing Zones, allowing seamless integration as part of a broader application landing zone strategy.


## Why Use this Module for AI Foundry Enterprise Deployments?

This module is particularly useful for AI Foundry enterprise deployments because it:

1. **Enhances Security**: Implements comprehensive security measures, including network isolation, private endpoints, identity management, and key vault integrations, ensuring that sensitive AI processes and data are protected against unauthorized access.

2. **Scalability**: Supports enterprise-grade deployments with scalable resources, allowing organizations to efficiently manage extensive AI workloads while preparing for future growth.

3. **Operational Efficiency**: Reduces setup time through predefined, opinionated end to end configurations, enabling faster deployment of infrastructure and services required for AI Foundry.

4. **Flexibility and Compliance**: Offers customizable options that align with diverse enterprise needs and comply with regulatory standards using managed access controls and automated role assignments.

5. **Integration**: Fits seamlessly into an Azure Landing Zone strategy, providing a cohesive cloud infrastructure deployment framework tailored for AI workloads, which helps in easy integration into broader cloud strategies.

6. **Networking and Identity Management**: Streamlines the deployment of complex networking architectures and identity management systems, ensuring efficient connectivity and access control.

This module implements the architecture as described in the [Azure AI Studio End-to-End Baseline Architecture](https://github.com/Azure-Samples/aistudio-end-to-end-baseline-architecture).

## Key Components

### Jumpbox Configuration
- **Purpose**: Acts as a secure bridge to the Azure environment by deploying a Windows-based jump box with isolated permissions.
- **Details**:
  - Configurable VM parameters, such as admin credentials and VM sizing.
  - Implements Azure Bastion for enhanced security and seamless access.
  - Network isolation via private IP setup.

### Networking Architecture
- **Purpose**: Establishes a secure and scalable network using Azure VNet, incorporating subnets, NSGs, private endpoints, and automated connectivity.
- **Details**:
  - Subnet configurations include app services, gateways, and additional environments.
  - Implements NSGs to manage traffic with detailed security rules.
  - Incorporates DDoS protection for enhanced security.

### AI Services Integration
- **Purpose**: Deploys advanced AI capabilities such as Azure Cognitive Services and Machine Learning, fostering AI-driven applications.
- **Details**:
  - Uses `azapi_resource` for creating AI hubs and projects.
  - Configures private endpoints for AI services to maintain privacy and security.
  - Customizable SKUs for resource optimization.

### Identity and Access Management (IAM)
- **Purpose**: Automates RBAC, ensuring authorized access to resources, making it simple to implement user personas and roles.
- **Details**:
  - Employs `azurerm_role_assignment` for dynamic role assignments.
  - Utilizes managed identities for accessing resources such as AI Search and OpenAI.
  - Define user groups and assign permissions.

### Storage Solutions
- **Purpose**: Provides secure and scalable storage tailored for AI workloads.
- **Details**:
  - Azure Storage Accounts with private endpoints for blob and file storage.
  - Enforces secure data transactions with network rule sets.
  - High availability through zone redundancy.

### Key Management and Security
- **Purpose**: Utilizes Azure Key Vault to securely store sensitive data, such as API keys.
- **Details**:
  - Sets up Key Vault access policies and role assignments.
  - Supports optional private DNS and endpoint configurations.

### DNS and Private Networking
- **Purpose**: Offers private DNS zones to manage internal domain names securely for services.
- **Details**:
  - Establishes private DNS zones linked with VNets.
  - Supports conditional DNS management for scalability.

### AI Landing Zone Compatibility
- **Purpose**: Easily integrates with AI Landing Zones for a cohesive application landing zone strategy.
- **Details**:
  - Enables seamless deployment within enterprise application strategies.
  - Establishes a consistent framework for cloud resources tailored to AI workloads.

### Shared Private Links
- **Purpose**: Implements Shared PrivateLinks to allow for private indexing of data using AI Search.
- **Details**:
  - Facilitates secure data access and indexing, enhancing data privacy and access control.
  - Supports AI-driven data queries and indexing in a private, secure network context.

## Ownership
- **Module Owner**: [FreddyAyala](https://github.com/FreddyAyala)

The module can be deployed as a layer and is considered an AI Landing Zone. It can be deployed standalone or as part of landing zones to be integrated into the platform landing zone.

## Requirements

The following requirements are needed by this module:

### Terraform
- **Version**: `>= 1.3.4`

### Providers
- **AzureRM Provider**
  - **Source**: `hashicorp/azurerm`
  - **Version**: `4.11.0`
- **AzAPI Provider**
  - **Source**: `azure/azapi`

## Resources

The following resources and modules are used by this module:

- `azurerm_resource_group.rg` (resource)
- `data.azurerm_resource_group.existing_rg` (data source)

### Conditioned Modules

- `module.ai_foundry_services` (conditional)
- `module.ai_foundry_core` (conditional)
- `module.ai_foundry_identity` (conditional)
- `module.ai_foundry_shared` (conditional)

## Required Inputs

The following input variables are required:

- **base_name**
  - Description: The base name for each Azure resource name.
  - Type: `string`

- **location**
  - Description: The resource group location.
  - Type: `string`
  - Default: `"East US"`

## Optional Inputs

The following input variables are optional and have default values:

- **tags**
  - Description: Map of tags to add to resources.
  - Type: `map(string)`
  - Default: `{}`

- **use_existing_rg**
  - Description: Flag to determine if an existing resource group should be used.
  - Type: `bool`
  - Default: `false`

- **existing_rg_name**
  - Description: Name of the existing resource group to use.
  - Type: `string`
  - Default: `""`

- **deploy_network**
  - Description: Flag to deploy network resources.
  - Type: `bool`
  - Default: `true`

- **role_templates**
  - Description: Templates for role assignments.
  - Type: `map(list(object))`
  - Default: `{ infra_admin: [...], ai_admin: [...] }`

- **network**
  - Description: Network configuration.
  - Type: `object`
  - Default configuration includes prefix settings for subnets.

- **deployment_config**
  - Description: Configuration to choose which layers to deploy.
  - Type: `object`
  - Default: `{ deploy_services: false, deploy_core: false, deploy_identity: false, deploy_shared: false }`

- **search_config**
  - Description: Configuration for the search service.
  - Type: `object`
  - Default: `{ ... }`

- **aiservice_config**
  - Description: Configuration for the AI service.
  - Type: `object`
  - Default: `{ ... }`

- **core_config**
  - Description: Configuration for ai-foundry-core module.
  - Type: `object`
  - Default: `{ ... }`

- Other variables related to network, principals, and role management.

## Outputs

The following outputs are exported:

- Outputs related to AI Hub, AI Services, and storage resources identifiers and states.

## Modules

The following sub-modules are called:

- **ai_foundry_services**
  - Source: `./modules/ai-foundry-services`

- **ai_foundry_core**
  - Source: `./modules/ai-foundry-core`

- **ai_foundry_identity**
  - Source: `./modules/ai-foundry-identity`

- **ai_foundry_shared**
  - Source: `./modules/ai-foundry-shared-resources`

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You can learn more about data collection and use in the [privacy statement](https://go.microsoft.com/fwlink/?LinkID=824704). Your use of the software operates as your consent to these practices.

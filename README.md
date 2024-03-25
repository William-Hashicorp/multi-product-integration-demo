# Multi Product Integration Demo

## Overview 

This repository is intended to help members of WWTFO quickly create reproducable demo environments which showcase:
- HCP Vault
- HCP Consul
- HCP Boundary
- HCP Packer
- Nomad Enterprise
- Terraform (TFC)

More importantly, the resulting environment is preconfigured to highlight the "better together" story, with a focus on interproduct integrations. A demo could span the entire environment or focus on any individual aspect.  The aim was to provide a very flexible environment which can be used as the basis for all usecase demos.

The following integrations are highlighted by default:
- **Terraform** is leveraged to deploy, configure, and integrate the other products
- **Vault** is used for dynamic credentials in several locations:
  - Dynamic Provider credentials used by **Terraform**
  - SSH signed Certificate injection in **Boundary**
  - Dynamic MongoDB credentials injection via **Nomad** templates
- **Packer** is used to create **Nomad** Server and Client AMIs in AWS
- **Terraform** integrates with **HCP Packer** for AMI management
- **Consul** service registration via **Nomad** 
- **Consul** Connect (service mesh) used by **Nomad** jobs

## Repository Structure

The entire environment is orchestrated by the "control-workspace" directory.  After completing a few prerequesite manual operations (which we will discuss below in the "Prerequisites" section), you will plan/apply the "control-workspace" in TFC.  This workspace will orchestrate the creation and triggering of all downstream workspaces (Shoutout to @lucymhdavies for the multi-space idea!).  
- **control-workspace**:  Orchestrates all other workspaces
- **networking**: Creates a VPC in AWS with 3 subnets, an HVN in HCP, and the peering connection between the two
- **hcp-clusters**: Creates an HCP Vault cluster, an HCP Boundary cluster, an HCP Consul cluster within the HVN
- **vault-auth-config**: On the first run, will utilize the root token generated in **hcp-clusters** to bootstrap Vault JWT Auth for Terraform Cloud.  After the first run this JWT Auth will be leverage by TFC for all subsequent runs that require Vault access
- **boundary-config**: Will configure the Boundary instance, configure the dynamic host catalogues, and integrate Vault for SSH signed cert injection
- **nomad-cluster**: Provisions a 3 node Nomad server cluster as an AWS ASG, boostraps its ACLs, and stores the bootstrap token in Vault
- **nomad-nodes**: Provisions 2 ASGs of 2 nodes each.  1 node pool for x86 nodes and 1 node pool for ARM nodes
- **workload**: Deploys 2 jobs to the Nomad cluster and configures Vault for dynamic MongoDB credentials:
  - Job 1 provisions a MongoDB instance
  - Integrates a Vault MongoDB secrets engine with the MongoDB instance
  - Job 2 provisions a frontend webapp, injecting credentials from vault, leveraging Consul connect for service communication

## Prerequisites

- You need a doormat created AWS sandbox account
- You need a HCP account with an organization scoped service principal
- You need a TFC account and a TFC user token 
- You need a pre-configured OAuth connection between TFC and GitHub

### Preparing your HCP Packer Registry

1) You must enable the HCP Packer registry before Packer can publish build metadata to it. Click the Create a registry button after clicking on the Packer link under "Services" in the left navigation. This only needs to be done once.

### Preparing your AWS account to leverage the doormat provider on TFC:

1) navigate to the doormat-prereqs directory
```
cd doormat-prereqs/
```
2) paste your doormat generated AWS credentials, exporting them to your shell
```
export AWS_ACCESS_KEY_ID=************************
export AWS_SECRET_ACCESS_KEY=************************
export AWS_SESSION_TOKEN=************************
```
3) Initialize terraform
```
terraform init
```
4) Run a plan passing in your TFC account name
```
terraform plan -var "tfc_organization=something"
```
5) Assuming everything looks good, run an apply passing in your TFC account name 
```
terraform apply -var "tfc_organization=something"
```

### Preparing your TFC account:

1) Create a new Project (I called mine "hashistack")
2) Run the doormat-prereqs/doormat-varset.sh script to set AWS credential in your TFC variable set.

3) Create a new Variable Set (again, I called mine "hashistack") and scope it to your previously created Project

4) Populate the variable set with the following variables:

| Key | Value | Sensitive? | Type |
|-----|-------|------------|------|
|boundary_admin_password|\<intended boundary admin password\>|yes|terraform|
|my_email|\<your email\>|no|terraform|
|nomad_license|\<your nomad ent license\>|yes|terraform|
|region|\<the region which will be used on HCP and AWS\>|no|terraform|
|stack_id|\<will be used to consistently name resources\>|no|terraform|
|tfc_organization|\<your TFC account name\>|no|terraform|
|HCP_CLIENT_ID|\<HCP Service Principal Client ID\>|no|env|
|HCP_CLIENT_SECRET|\<HCP Service Principal Client Secret\>|yes|env|
|HCP_PROJECT_ID|\<your HCP Project ID retrieved from HCP\>|no|env|
|TFC_WORKLOAD_IDENTITY_AUDIENCE|\<can be literally anything\>|no|env|
|TFE_TOKEN|\<TFC User token\>|yes|env|
|aws_account_id|aws account id of your doormat was account. You can get from the doormat-prereqs output|no|terraform|

4) Create a new workspace within your TFC project called "0_control-workspace", attaching it to this VCS repository, specifying the working directory as "0_control-workspace"

5) Create the following workspace variables within "0_control-workspace":

| Key | Value | Sensitive? | Type |
|-----|-------|------------|------|
|oauth_token_id|\<the ot- ID of your OAuth connection\>|no|terraform|
|repo_identifier|djschnei21/multi-product-integration-demo|no|terraform|
|tfc_project_id|\<the prj- ID of your TFC Project\>|no|terraform|
|repro_branch|default is the main branch|no|terraform|

## Building the Nomad AMI using Packer

1) navigate to the packer directory
```
cd packer/
```
2) paste your doormat generated AWS credentials, exporting them to your shell
```
export AWS_ACCESS_KEY_ID=************************
export AWS_SECRET_ACCESS_KEY=************************
export AWS_SESSION_TOKEN=************************
```
3) export your HCP_CLIENT_ID and HCP_CLIENT_SECRET to your shell
```
export HCP_CLIENT_ID=************************                                    
export HCP_CLIENT_SECRET=************************
```
4) Trigger a packer build specifying a pre-existing, publicly accesible subnet of your AWS account for build to happen within
```
packer build -var "subnet_id=subnet-xxxxxxxxxxxx" ubuntu.pkr.hcl
```

## Triggering the deployment

Now comes the easy part, simply trigger a run on "0_control-workspace" and watch the environment unfold! 


## Steps to deploy Nomad jobs:
• Create a workspace called "7_workload" under the same project.

• If have not, Run the doormat prepare job again to add doormat permission.

• Trigger Apply for the workspace to deploy Nomad jobs

• Show the nomad template code to show Vault's Dynamic MongoDB credentials injection 


## Demo Steps

1. Once the run is complete, you can access each tool by:
- **HCP Consul**: Navigate to the cluster in HCP and generate a root token
- **HCP Vault**: Navigate to the cluster in HCP and generate a root token
- **HCP Boundary**: Navigate to the cluster in HCP or via the Desktop app:
  - *username*: admin
  - *password*: this is whatever you set in the variable set
- **Nomad Ent**: The "5_nomad-cluster" workspace will have an output containing the public ALB endpoint to access the Nomad UI.  The Admin token for this can be retrieved from Vault using
```
vault kv get -mount=hashistack-admin/ nomad_bootstrap/SecretID
```

2. Nomad CLI
```
export NOMAD_ADDR=xxx
export NOMAD_TOKEN=xxx

nomad job status
nomad job status demo-frontend
```

In case we need to connect SSH to the container:

```
nomad alloc exec -task frontend -job demo-frontend /bin/sh

cd /secrets
cat mongoku.env
```

3. Run the script below in the ./workload folder to show the current lease ID of the mongodb secret engine. 


```
./monitor_secrets.sh 
```

Compare the TTL, if we go to the Nomad portal, and see if nomad job is restart automatically. Since the dynamic database credential's TTL is 3min and max ttl is 10min, the container will restart after and get new connections and dynamic credentials.


4. To access the demo application:

• Go to the nomad interface or aws console, we will get the public ip of the node. 
• Visit the website with http://node public ip address:3100


• We can disable/enable the intention to disable/allow frontend to mongodb
• After that, we can stop and restart the nomad job, and try to access again, we will see the difference.

5. Terraform is leveraged to deploy, configure, and integrate the other products

  • Show the availability to deploy a whole system via CICD pipeline with Github
  • Variable sets
  • Project and workspaces
  • Cost estimation
  • Enable run task checking for post-plan


6. Vault is used for dynamic credentials in several locations:
  • Dynamic Provider credentials used by Terraform
  • SSH signed Certificate injection in Boundary
  • Dynamic MongoDB credentials injection via Nomad templates
  
• Dynamic Provider credentials
  • Show the varset Variable set: project_vault_auth_hashistack
  • It configures OIDC trust with a defined role "project_role" with HCP vault
  • No credential is required in Terraform

7. Boundary demo
  • In the Terraform code, show the 3 boundary host sets are built based on ASG tags. This is the dynamic host set. 
  
  • Install boundary CLI and desktop if there isn't
  • https://developer.hashicorp.com/boundary/install
  • Show SSH session to remote nomad hosts with desktop client.
  ssh 127.0.0.1 -p xxxxx

  • Show SSH session to remote nomad hosts with CLI .
```
export BOUNDARY_USER=admin
export BOUNDARY_ADDR=https://f81ef0ee-d8ed-448f-b0f4-b20260c9c2e1.boundary.hashicorp.cloud
export BOUNDARY_PASSWORD=xxx
export BOUNDARY_AUTH_METHOD=ampw_YXQZ45U5Ms
export BOUNDARY_TOKEN=$(boundary authenticate password -login-name=$BOUNDARY_USER \
  -password env://BOUNDARY_PASSWORD \
  -auth-method-id=$BOUNDARY_AUTH_METHOD \
  -keyring-type=none \
  -format=json \
  | jq -r '.item.attributes.token')

echo $BOUNDARY_TOKEN

#list out the target IDs
boundary targets list -scope-id <project_id>

export TARGET_ID=xxxxxxxxxx

boundary targets read -id $TARGET_ID

# automatic inject ssh certificates

boundary connect ssh -target-id $TARGET_ID

```

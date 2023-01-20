# Overview

This is an example implementation of the [terraform-google-kubernetes](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine) Terraform module, specifically demonstrating the creation of:
- Private GKE Cluster in a Service Project of a Shared VPC
- Installation of Anthos Service Mesh (Managed Control Plane)
- Installation of Anthos Config Management
- Deployment of example Policy Controller policies
- Deployment of an application to the cluster via Config Sync

It requires only a single Project that acts as the central CICD project for further infrastructure roll out. Pre-reqs:
- Create a Project and enable billing
- Enable Cloud Source Repos and sync this git project with a new Cloud Source Repos directory in the Project.

The following will then be provisioned by Terraform:
- Host Project 
- Service Project
- Shared VPC with Subnets shared to the Service Project
- Secondary ranges for Pods and Services on the Subnet shared to the Service Project
- Private GKE cluster in the Service Project
- ASM and ACM installed on the cluster
- ACM Config Sync configured to synchronise with the [apps/](apps/) directory


The majority of the Infrastructure Deployment is performed via Terraform. It adopts a layered Terraform approach. Each layer is completely independent with separate configuration and state. There may however be some dependenices between the layers, these dependencies should all be one-way (dependency from a higher layer to a lower-layer only).

The current layers are found in the [infrastructure/](infrastructure/) directory, and are detailed below:

| Path                                           | Description                                                                                                                                |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [infrastructure/layers/init](infrastructure/layers/init/README.md)                     | Configures the deployment project that is used for storing code and running Cloud Build to apply subsequent layers to environment projects |
| [infrastructure/layers/001-bootstrap](infrastructure/layers/001-bootstrap/README.md)   | Initial Project Bootstrap layer. Responsible for Project creation as well as IAM and API Enablement                                                                    |
| [infrastructure/layers/002-cluster](infrastructure/layers/002-cluster/README.md)       | Builds out the cluster and configures ASM                                                                                                  |
| [infrastructure/layers/003-apps](infrastructure/layers/003-apps/README.md)             | Deploys applications such as Onlineboutique                                                                                                |

## Deployment

By default, the repo uses Cloud Build as the environment to apply the terraform from, and by default will run the Cloud Build builds from the CICD Project. All additional Projects will be created automatically from this Project. The configuration for the Cloud Build triggers and execution YAML are available in the [build](build) directory.

Terraform State is also stored in the CICD Project, in a bucket that gets created by the first init terraform. By default this is called `gs://	shared-infra-cicd-tfstate-mono`.

### Setup

To setup the the deployment Project from scratch, perform the following steps using gcloud

1. Setup Environment

```
# Edit the below with your CICD Project details
CICD_PROJECT_ID=<YOUR CI/CD PROJECT>
gcloud config set project $CICD_PROJECT_ID
CICD_PROJECT_NUMBER=$(gcloud projects describe $CICD_PROJECT_ID --format 'value(projectNumber)')
REPO_NAME=<YOUR CLOUD SOURCE REPOSITORY NAME WITHIN YOUR CICD PROJECT>
BILLING_ACCOUNT=<YOUR BILLING ACCOUNT ID>
FOLDER_ID=<YOUR GCP FOLDER CONTAINING THE CICD PROJECT>
ORG_ID=<YOUR GCP ORG ID>
```

```
# Edit the below with the configuration for your new Host and Service Projects (to be created via Terraform)
HOST_PROJECT_ID=<YOUR DESIRED HOST PROJECT ID>
SERVICE_PROJECT_ID=<YOUR DESIRED SERVICE PROJECT ID>
```

2. Enable APIs in the CICD Project

```
gcloud services enable iam.googleapis.com cloudbuild.googleapis.com servicenetworking.googleapis.com container.googleapis.com sqladmin.googleapis.com cloudresourcemanager.googleapis.com cloudbilling.googleapis.com
```

3. Create GCS Bucket for Init State

**NB: You will need to use a unique name if creating a new bucket**

```
gsutil mb gs://$CICD_PROJECT_ID-init-state
gsutil versioning set on gs://$CICD_PROJECT_ID-init-state
```

4. Grant Cloud Build in the CICD Project permission to manage the GCS Bucket for Init State

```
gsutil iam ch serviceAccount:$CICD_PROJECT_NUMBER@cloudbuild.gserviceaccount.com:objectAdmin gs://$CICD_PROJECT_ID-init-state
```

5. Grant Cloud Build in the CICD Project permission to manage the CICD Project

```
gcloud projects add-iam-policy-binding $CICD_PROJECT_ID --member=serviceAccount:$CICD_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/owner
```

6. Grant Cloud Build in the CICD Project permission to manage the Billing Account

```
gcloud beta billing accounts add-iam-policy-binding $BILLING_ACCOUNT --member=serviceAccount:$CICD_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/billing.admin
```

1. Grant Cloud Build in the CICD Project permission to manage the Folder and create Projects within it

```
gcloud resource-manager folders add-iam-policy-binding $FOLDER_ID --member=serviceAccount:$CICD_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.projectCreator

gcloud resource-manager folders add-iam-policy-binding $FOLDER_ID --member=serviceAccount:$CICD_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.folderIamAdmin

gcloud organizations add-iam-policy-binding $ORG_ID --member=serviceAccount:$CICD_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.organizationAdmin
```

8. Apply the Build Trigger

```
gcloud beta builds triggers create cloud-source-repositories --name=infrastructure-layer-init-apply --repo=$REPO_NAME --branch-pattern=master --build-config=build/config/infrastructure/init/cloudbuild.yaml --included-files=infrastructure/layers/init/** --substitutions _CICD_PROJECT_=$CICD_PROJECT_ID,_REPO_NAME_=$REPO_NAME,_HOST_PROJECT_=$HOST_PROJECT_ID,_SERVICE_PROJECT_=$SERVICE_PROJECT_ID,_BILLING_ACCOUNT=$BILLING_ACCOUNT,_LAYER_NAME_=init
```

9. Run the Build for the init layer. This will run the Teffarorm in [infrastructure/layers/init](infrastructure/layers/init/README.md) to create the Build Triggers for the other layers. Once this runs, you can see the other Triggers ready to run to apply the additional layers of terraform.
```
gcloud beta builds triggers run infrastructure-layer-000-init --project=$CICD_PROJECT_ID --branch=master
```

10. Run the Build Trigger for the 001-Bootstrap Layer

```
gcloud beta builds triggers run infrastructure-layer-001-bootstrap-apply --project=$CICD_PROJECT_ID --branch=master
```

11. Run the Build Trigger for the 002-networking Layer

```
gcloud beta builds triggers run infrastructure-layer-002-cluster-dev --project=$CICD_PROJECT_ID --branch=master
```

12. Run the Build Trigger for the 003-cluster Layer

```
gcloud beta builds triggers run infrastructure-layer-003-cluster-dev --project=$CICD_PROJECT_ID --branch=master
```

### Further changes

The Cloud Build triggers are set up to automatically start builds for each layer if there are changes to files within that later. Simply commit and push to the repo, and Cloud Build builds will run according to the changes.
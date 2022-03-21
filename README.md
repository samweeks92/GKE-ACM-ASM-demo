# Overview

This is an example implementation of the [terraform-google-kubernetes](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine) Terraform module, specifically demonstrating the creation of:
- Private GKE Cluster in a Service Project of a Shared VPC
- Installation of Anthos Service Mesh (managed control plane)
- Example of deploying an application to the cluster via the [hashicorp/kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) provider

It requires the following prereqs to be in place in the environment:
- Host Project 
- Service Project
- Shared VPC with Subnets shared to the Service Project
- Secondary ranges for Pods and Services on the Subnet shared to the Service Project
- Cloud Source Repos setup as a git remote origin for repo (or mirrored from a remote origin)

The majority of the Infrastructure Deployment is performed via Terraform. It adopts a layered Terraform approach. Each layer is completely independent with separate configuration and state. There may however be some dependenices between the layers, these dependencies should all be one-way (dependency from a higher layer to a lower-layer only).

The current layers are found in the [infrastructure/](infrastructure/) directory, and are detailed below:

| Path                                           | Description                                                                                                                                |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [infrastructure/layers/init](infrastructure/layers/init/README.md)                     | Configures the deployment project that is used for storing code and running Cloud Build to apply subsequent layers to environment projects |
| [infrastructure/layers/001-bootstrap](infrastructure/layers/001-bootstrap/README.md)   | Initial Project Bootstrap layer. Responsible for IAM and API Enablement                                                                    |
| [infrastructure/layers/002-cluster](infrastructure/layers/002-cluster/README.md)       | Builds out the cluster and configures ASM                                                                                                  |
| [infrastructure/layers/003-apps](infrastructure/layers/003-apps/README.md)             | Deploys applications such as Onlineboutique                                                                                                |

## Deployment

By default, the repo uses Cloud Build as the environment to apply the terraform from, and by default will run the Cloud Build builds from the Host Project. In reality, best practices are to use a dedicated Project for CI/CD processes, however for this demo example the Host Project is reused for this purpose. The configuration for the Cloud Build triggers and execution YAML are available in the [build](build) directory.

Terraform State is also stored in the Host Project, in a bucket that gets created by the first init terraform. By default this is called `gs://service-project-01-tfstate-mono`. Again, in reality this would sit in the dedicated CI/CD Project. 

### Setup

To setup the the deployment Project from scratch, perform the following steps using gcloud

1. Setup Environment

```
# Edit the below with your new deploy project
DEPLOY_PROJECT_ID=<YOUR CI/CD PROJECT (or Host Project)>
gcloud config set project $DEPLOY_PROJECT_ID
DEPLOY_PROJECT_NUMBER=$(gcloud projects describe $DEPLOY_PROJECT_ID --format 'value(projectNumber)')
```

2. Enable APIs in the deploy Project

```
gcloud services enable iam.googleapis.com cloudbuild.googleapis.com servicenetworking.googleapis.com container.googleapis.com sqladmin.googleapis.com cloudresourcemanager.googleapis.com
```

3. Create GCS Bucket for Init State

**NB: You will need to use a unique name if creating a new bucket**

```
gsutil mb gs://service-project-01-init-state
gsutil versioning set on gs://service-project-01-init-state
```

4. Grant Cloud Build in the deploy Project access to GCS Bucket

```
gsutil iam ch serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com:objectAdmin gs://service-project-01-init-state
```

5. Grant Cloud Build in the deploy Project permission to manage the build Project

```
gcloud projects add-iam-policy-binding $DEPLOY_PROJECT_ID --member=serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/owner
```

6. Grant Cloud Build in deploy Projects permission to deploy to resource Projects

**Substitute the below project ID's with the project ID's for prod, pre-prod and dev if applicable**

```
gcloud projects add-iam-policy-binding <service-project-id> --member=serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/owner
```

7. Apply the Build Trigger

```
gcloud beta builds triggers import --project=$DEPLOY_PROJECT_ID --source=build/triggers/infrastructure/init/init-build-trigger.yaml
```

8. Run the Build for the init layer. This will run the Teffarorm in [infrastructure/layers/init](infrastructure/layers/init/README.md) to create the Build Triggers for the other layers. Once this runs, you can see the other Triggers ready to run to apply the additional layers of terraform.
```
gcloud beta builds triggers run infrastructure-layer-000-init --project=$DEPLOY_PROJECT_ID --branch=master
```

9. Run the Build Trigger for the 001-Bootstrap Layer

```
gcloud beta builds triggers run infrastructure-layer-001-bootstrap-dev --project=$DEPLOY_PROJECT_ID --branch=master
```

11. Run the Build Trigger for the 002-cluster Layer

```
gcloud beta builds triggers run infrastructure-layer-002-cluster-dev --project=$DEPLOY_PROJECT_ID --branch=master
```

12. Run the Build Trigger for the 003-apps Layer

```
gcloud beta builds triggers run infrastructure-layer-003-apps-dev --project=$DEPLOY_PROJECT_ID --branch=master
```

### Further changes

The Cloud Build triggers are set up to automatically start builds for each layer if there are changes to files within that later. Simply commit and push to the repo, and Cloud Build builds will run according to the changes.
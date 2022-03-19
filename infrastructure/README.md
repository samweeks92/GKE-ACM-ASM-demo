# Infrastructure

This repository contains all of the configuration and documentation for environment deployment.

The majority of the Infrastructure Deployment is performed via Terraform. It adopts a layered Terraform approach. Each layer is completely independent with separate configuration and state. There may however be some dependenices between the layers, these dependencies should all be one-way (dependency from a higher layer to a lower-layer only).

The current layers are detailed below:

| Path                                           | Description                                                                                                                                |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [layers/init](layers/init)                     | Configures the deployment project that is used for storing code and running Cloud Build to apply subsequent layers to environment projects |
| [layers/001-bootstrap](layers/001-bootstrap)   | Initial Project Bootstrap layer. Responsible for IAM and API Enablement                                                                    |
| [layers/002-cluster](layers/002-cluster)         | builds out the cluster and configures ASM                                              |                                                        |

## Deployment

Deployment is performed automatically using Cloud Build. The configuration for the Cloud Build triggers and execution YAML are available in the [build](build) directory.

This repo assumes there is already the following resources:
- Host Project
- Service Project
- Shared VPC
- Subnet shared to the Service Project
- Secondary ranges for Pods and Services that sit on the Subnet shared to the Service Project

By default, all builds are performed from the Host Project, but in reality one would adopt a dedicated Project for CI/CD.

Terraform State is also stored in the Host Project, in a bucket that gets created by the first init terraform later. By default this is called `gs://service-project-01-tfstate-mono`. Again, in reality this would sit in the dedicated CI/CD Project. 

### Initial Setup

To setup the the deployment project from scratch, perform the following steps using gcloud

1. Setup Environment

```
# Edit the below with your new deploy project
DEPLOY_PROJECT_ID=<YOUR CI/CD PROJECT (or Host Project)>
gcloud config set project $DEPLOY_PROJECT_ID
DEPLOY_PROJECT_NUMBER=$(gcloud projects describe $DEPLOY_PROJECT_ID --format 'value(projectNumber)')
```

2. Enable APIs in the Deploy Poject

```
gcloud services enable iam.googleapis.com cloudbuild.googleapis.com servicenetworking.googleapis.com container.googleapis.com sqladmin.googleapis.com cloudresourcemanager.googleapis.com
```

3. Create GCS Bucket for Init State

**NB: You will need to use a unique name if creating a new bucket**

```
gsutil mb gs://service-project-01-init-state
gsutil versioning set on gs://service-project-01-init-state
```

4. Grant GCB in the deploy project access to GCS Bucket

```
gsutil iam ch serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com:objectAdmin gs://service-project-01-init-state
```

5. Grant GCB in the deploy project permission to manage the build project

```
gcloud projects add-iam-policy-binding $DEPLOY_PROJECT_ID --member=serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/owner
```

6. Grant Cloud Build in Deploy Projects permission to deploy to resource projects

**Substitute the below project ID's with the project ID's for prod, pre-prod and dev if applicable**

```
gcloud projects add-iam-policy-binding <service-project-id> --member=serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/owner
```

7. Review all variables across the files in the source code and adjust for GCS terraform state Bucket names, projectIDs, user identities, service accounts, IAM preferences and DNS settings. 


8. Apply the Build Trigger

```
gcloud beta builds triggers import --project=$DEPLOY_PROJECT_ID --source=build/triggers/infrastructure/init/init-build-trigger.yaml
```

9. Run the Build for the init layer
```
gcloud beta builds triggers run infrastructure-layer-000-init --project=$DEPLOY_PROJECT_ID --branch=master
```

10. Run the Build Trigger for the 001-Bootstrap Layer

```
gcloud beta builds triggers run infrastructure-layer-001-bootstrap-dev --project=$DEPLOY_PROJECT_ID --branch=master
```

11.  Run the Builds for the additional infractructure layers

12.  Following a successful rollout of the terraform, we can continue to roll out the applications. Each of these are also deployed via Cloud Build, and each has a Cloud Build trigger to be created. Proceed to reach of the README files within /frontend, /query-engine, /ingestion-engine, /processing-engine and /rules-engine to see the instructions for creating the required Cloud Build triggers and deploying the applications. 

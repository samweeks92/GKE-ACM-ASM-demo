# Infrastructure

This repository contains all of the configuration and documentation for environment deployment.

The majority of the Infrastructure Deployment is performed via Terraform. We adopt a layered Terraform approach. Each layer is completely independent with separate configuration and state. There may however be some dependenices between the layers, these dependencies should all be one-way (dependency from a higher layer to a lower-layer only).

The current layers are detailed below:

| Path                                           | Description                                                                                                                                |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [layers/init](layers/init)                     | Configures the deployment project that is used for storing code and running Cloud Build to apply subsequent layers to environment projects |
| [layers/001-bootstrap](layers/001-bootstrap)   | Initial Project Bootstrap layer. Responsible for IAM and API Enablement                                                                    |
| [layers/002-manual](layers/002-manual)         | Initial set of manual steps that must be performed for each project, this cannot be automated                                              |
| [layers/003-networking](layers/003-networking) | Deploys and manages all of the networking configuration                                                                                    |
| [layers/004-compute](layers/004-compute)       | Deploys and manages the shared compute layer in the project including GKE                                                                  |

## Deployment

Deployment is performed automatically using Cloud Build. The configuration for the Cloud Build triggers and execution YAML are available in the [build](build) directory. All builds are performed from a separate project [fsus-deploy](https://pantheon.corp.google.com/home/dashboard?project=fsus-deploy&folder=&organizationId=) into the respective Global Sourcing Explorer projects. This is to prevent accidental permission inheritence.

Terraform State is also stored in the [fsus-deploy](https://pantheon.corp.google.com/home/dashboard?project=fsus-deploy&folder=&organizationId=) project, in a bucket that gets created by the first init terraform later. By default this is called `gs://gfie-terraform-tfstate-mono`. 

### Initial Setup

To setup the the deployment project from scratch, perform the following steps using gcloud

1. Setup Environment

```
# Edit the below with your new deploy project
DEPLOY_PROJECT_ID=hostproject-svpc-01
gcloud config set project $DEPLOY_PROJECT_ID
DEPLOY_PROJECT_NUMBER=$(gcloud projects describe $DEPLOY_PROJECT_ID --format 'value(projectNumber)')
```

2. Enable APIs in the Deploy Poject

```
gcloud services enable iam.googleapis.com cloudbuild.googleapis.com servicenetworking.googleapis.com container.googleapis.com sqladmin.googleapis.com
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
gcloud projects add-iam-policy-binding fsus-prod --member=serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/owner
gcloud projects add-iam-policy-binding fsus-preprod --member=serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/owner
gcloud projects add-iam-policy-binding fsus-dev --member=serviceAccount:$DEPLOY_PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/owner
```

7. Review all variables across the files in the source code and adjust for GCS terraform state Bucket names, projectIDs, user identities, service accounts, IAM preferences and DNS settings. 


8. Apply the Build Trigger

```
gcloud beta builds triggers import --project=$DEPLOY_PROJECT_ID --source=build/triggers/infrastructure/init/fsus-deploy.yaml
```

9. Run the Build for the init layer
```
gcloud beta builds triggers run fsus-deploy-init --project=$DEPLOY_PROJECT_ID --branch=master
```

10. Run the Build Triggers for the 001-Bootstrap Layer

```
gcloud beta builds triggers run infrastructure-layer-001-bootstrap-dev --project=$DEPLOY_PROJECT_ID --branch=master
gcloud beta builds triggers run infrastructure-layer-001-bootstrap-preprod --project=$DEPLOY_PROJECT_ID --branch=master
gcloud beta builds triggers run infrastructure-layer-001-bootstrap-prod --project=$DEPLOY_PROJECT_ID --branch=master
```

10. Perform one-time manual configuration

Certain steps cannot be automated, follow the one-time steps defined in the [layers/002-manual](layers/002-manual) directory

11. Run the Builds for the additional infractructure layers

12. Following a successful rollout of the terraform, we can continue to roll out the applications. Each of these are also deployed via Cloud Build, and each has a Cloud Build trigger to be created. Proceed to reach of the README files within /frontend, /query-engine, /ingestion-engine, /processing-engine and /rules-engine to see the instructions for creating the required Cloud Build triggers and deploying the applications. 

# Query Engine CI Tests

There are automated tests that are triggered when a new change is created in Gerrit for the [/infrastructure/layers/layer-002-cluster](/infrastructure/layers/layer-002-cluster) directory.

These tests are defined in the [/build/config/infrastructure/global/cloudbuild-tests.yaml](/build/config/infrastructure/global/cloudbuild-tests.yaml) file.

These are configured via a special Google-Internal configuration that enables the linking of Google Cloud Build and Gerrit.

Full instructions are in [this internal doc](https://docs.google.com/document/d/1nYQyVbPjcBMYJi7Dtht3bH39Zbu6c5Say3hcQ6ES9jI/edit#), a summarised version is included below

If the repo ever moves from Gerrit, then these should be replaced with a trigger for the respective platforms change equivalent (PR, etc).

## Setup Commands

Must be run from a CloudTop with Prodaccess.

1. Mint credentials
```
/google/data/ro/projects/gaiamint/bin/get_mint --type=loas --out=/tmp/mint.txt --scopes=35600 --endusercreds
```

2. Create trigger
```
stubby call --rpc_creds_file=/tmp/mint.txt blade:alphasource-ci-proctor-metadata-service-prod ProctorMetadataService.CreateTrigger --proto2 <<EOF
trigger {
  cloud_project_number: 420156769072
  name: "infrastructure-layer-002-cluster-tests"
  description: "Unit Tests on Gerrit Change creation for the infrastructure layer-003 deployment"
  gerrit_trigger {
    host: "partner-code"
    project: "hostproject-svpc-01"
    branch: "master"
    included_files: "infrastructure/layers/002-cluster/**"
  }
  build_configs {
    file_source {
        path: "build/config/infrastructure/global/cloudbuild-tests.yaml"
    }
    substitutions {
      key: "_LAYER_NAME_"
      value: "002-cluster"
    }
    substitutions {
      key: "_ENVIRONMENT_"
      value: "dev"
    }
    substitutions {
      key: "_DEPLOY_PROJECT_"
      value: "serviceproject01-svpc-01"
    }
  }
  result_config {
    code_review_config {
      notify_condition {
        condition: ALWAYS
      }
      update_status: true
      status_name: "Code-Review"
    }
  }
}
EOF
```
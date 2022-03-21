# /init Trigger

This is the config for the Cloud Build Trigger for the [../../../../infrastructure/layers/init](../../../../infrastructure/layers/init/README.md) terraform layer. This layer requires this Cloud Build configuration and associated trigger to be applied to Google Cloud manually (e.g. via gcloud rather than Terraform). The role of this layer is to apply terraform to create all the other Cloud Build config for the subsequent layers.

Refer to the root [README.md](../../../../README.md) to instructions for creating and running the init Trigger.
# Global

Most layers of the Terraform do not require a bespoke `cloudbuild.yaml` for each layer.

This directory contains a global `cloudbuild.yaml` that can be re-used for all layers. Customisation is performed via the substitutions in the Build Triggers. By default, the [../../../../infrastructure/layers/init](../../../../infrastructure/layers/init/README.md) terraform layer will create configure the Cloud Build Triggers to use this `cloudbuild.yaml` config file for each of the subsequent layers.

Refer to the root [README.md](../../../../README.md) to instructions for running the Triggers for each layer after they have been created by the init layer.
# Global

Most layers of the Terraform do not require a bespoke `cloudbuild.yaml` for each layer.

This directory contains a global `cloudbuild.yaml` that can be re-used for all layers. Customisation is performed via the substitutions in the Build Triggers.
# /init

This directory contains the Terraform configuration for the init layer. 

It runs from the deployment Project (by default the Host Project) via Cloud Build, and the creation of the Cloud Build configuration and Triggers is done as a a manual step which is documented in the root [README.md](../../../README.md) which contains all of the Cloud Build and repositories that are then deployed to the environment Project(s).
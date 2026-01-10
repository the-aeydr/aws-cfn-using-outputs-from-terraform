# Terraform AWS CloudFormation Outputs

A Terraform module that is responsible for provisioning two CloudFormation Stacks, both of which are responsible for making a set of prefix list IDs available to CloudFormation. One of the stacks uses CloudFormation outputs for exposing the outputs, while the other makes them available as parameter store values.

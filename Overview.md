# Using empty CloudFormation Stacks to publish outputs for CloudFormation

This is a companion repository for the written article 'Using empty CloudFormation Stacks to publish outputs for CloudFormation', which demonstrates examples of CloudFormation Templates which pass outputs from Terraform and into CloudFormation. These CloudFormation Templates are handwritten, but in practice would rely on frameworks such as AWS Cloud Development Kit (CDK) to construct the templates.

## Getting Started

For working with the repository, you will need an [Amazon Web Services (AWS)](https://aws.amazon.com/) account, for which the permissions are sufficient to provision and destroy CloudFormation Stacks. For simplicity, a [gitpod](./.gitpod) environment is included with the repository, should you be familiar with Cloud Development Environments (CDEs).

If you are working locally, you will need to ensure that the following tools are installed:

- [make](https://www.gnu.org/software/make/)
- [awscli](https://aws.amazon.com/cli/)

This repository uses `make` as a task runner & interface for the CloudFormation commands. It is recommended when entering the repository within the Development Environment to run `make help` to see a list of available commands, and the related documentation.

> `make help` is only accessible from within the [development environment](./.gitpod), as it is imported from the `GLOBAL_MAKEFILE_LIBRARY`.

## Deploying into CloudFormation

> Before starting you should make sure you have authenticated to AWS with the [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

To initialize an empty CloudFormation Stack that creates no resources, you can run the make command `cfn-init`. This will deploy into CloudFormation a stack that uses a `WaitConditionHandle` as the sole resource. You can run this as follows:

```bash
make cfn-init
```

This will construct a stack with the name `aws-cfn-unique-resource-names`, as seen in the command logs:

```text

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - aws-cfn-unique-resource-names
```

> You can modify the CloudFormation stack name using the `STACK_NAME` variable

The CloudFormation template that has been deployed is located at [cloudformation/01-empty/stack.template.yaml](cloudformation/01-empty/stack.template.yaml), which contains just metadata and the `WaitConditionHandle`. The [WaitConditionHandle](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-waitconditionhandle.html) resource is necessary as a CloudFormation stack cannot be created without resources, and a `WaitConditionHandle` is an internal stack resource that doesn't require us to provision anything within AWS. Provisioning this allows us to get a working CloudFormation Stack without needing to worry about troubleshooting a failed stack create.

With the stack created, you can now provision the CloudFormation stacks for import using Terraform. For this use case, it will rely on the default set of EC2 prefix lists provided by Amazon for DynamoDB, CloudFront and S3. These will be looked up by Terraform, and encoded into the CloudFormation Stacks as outputs. You can provision these stacks by running the command:

```bash
make tf-stack
```

This will configure the cloudformation templates that encode the outputs for use by CloudFormation. The first stack relies on [CloudFormation outputs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) to store the values, and the second stack uses parameter store resources to store the values, exporting the names of these parameter store values. The logs from provisioning this updated template should be as follows:

```text
terraform -chdir=./modules/terraform-aws-cloudformation-outputs init
terraform -chdir=./modules/terraform-aws-cloudformation-outputs apply -auto-approve

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.8.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
data.aws_ec2_managed_prefix_lists.aws_managed_lists: Reading...
data.aws_region.current: Reading...
data.aws_region.current: Read complete after 0s [id=ca-central-1]
data.aws_ec2_managed_prefix_lists.aws_managed_lists: Read complete after 1s [id=ca-central-1]
data.aws_ec2_managed_prefix_list.aws_managed_list[3]: Reading...
data.aws_ec2_managed_prefix_list.aws_managed_list[0]: Reading...
data.aws_ec2_managed_prefix_list.aws_managed_list[2]: Reading...
data.aws_ec2_managed_prefix_list.aws_managed_list[1]: Reading...
data.aws_ec2_managed_prefix_list.aws_managed_list[3]: Read complete after 0s [id=pl-7da54014]
data.aws_ec2_managed_prefix_list.aws_managed_list[2]: Read complete after 0s [id=pl-4ea54027]
data.aws_ec2_managed_prefix_list.aws_managed_list[1]: Read complete after 0s [id=pl-38a64351]
data.aws_ec2_managed_prefix_list.aws_managed_list[0]: Read complete after 0s [id=pl-08a6a3685cc410c2d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudformation_stack.outputs will be created
  + resource "aws_cloudformation_stack" "outputs" {
      + id            = (known after apply)
      + name          = "aws-cfn-using-outputs-from-terraform-outputs"
      + outputs       = (known after apply)
      + parameters    = (known after apply)
      + policy_body   = (known after apply)
      + tags_all      = (known after apply)
      + template_body = jsonencode(
            {
              + AWSTemplateFormatVersion = "2010-09-09"
              + Outputs                  = {
                  + Dynamodb                     = {
                      + Description = "An output exported from Terraform"
                      + Export      = {
                          + Name = {
                              + "Fn::Sub" = "${AWS::StackName}-Dynamodb"
                            }
                        }
                      + Value       = "pl-4ea54027"
                    }
                  # ...
                  + S3                           = {
                      + Description = "An output exported from Terraform"
                      + Export      = {
                          + Name = {
                              + "Fn::Sub" = "${AWS::StackName}-S3"
                            }
                        }
                      + Value       = "pl-7da54014"
                    }
                }
              + Resources                = {
                  + WaitHandle90462e8da7448971ec6ebb943c38a037d8725e298cb8ddb30c6ad06beb73b2bc = {
                      + Type = "AWS::CloudFormation::WaitConditionHandle"
                    }
                }
            }
        )
    }

  # aws_cloudformation_stack.parameters will be created
  + resource "aws_cloudformation_stack" "parameters" {
      + id            = (known after apply)
      + name          = "aws-cfn-using-outputs-from-terraform-outputs-params"
      + outputs       = (known after apply)
      + parameters    = (known after apply)
      + policy_body   = (known after apply)
      + tags_all      = (known after apply)
      + template_body = jsonencode(
            {
              + AWSTemplateFormatVersion = "2010-09-09"
              + Outputs                  = {
                  + Dynamodb                     = {
                      + Description = "The name of a parameter store entry that contains a value exported from Terraform"
                      + Export      = {
                          + Name = {
                              + "Fn::Sub" = "${AWS::StackName}-Dynamodb"
                            }
                        }
                      + Value       = {
                          + Ref = "Dynamodb"
                        }
                    }
                  # ...
                  + S3                           = {
                      + Description = "The name of a parameter store entry that contains a value exported from Terraform"
                      + Export      = {
                          + Name = {
                              + "Fn::Sub" = "${AWS::StackName}-S3"
                            }
                        }
                      + Value       = {
                          + Ref = "S3"
                        }
                    }
                }
              + Resources                = {
                  + Dynamodb                     = {
                      + Properties = {
                          + Description = "An output exported from Terraform, made available for CloudFormation"
                          + Name        = {
                              + "Fn::Sub" = [
                                  + "/cloudformation/${StackName}/Dynamodb",
                                  + {
                                      + StackName = {
                                          + Ref = "AWS::StackName"
                                        }
                                    },
                                ]
                            }
                          + Type        = "String"
                          + Value       = "pl-4ea54027"
                        }
                      + Type       = "AWS::SSM::Parameter"
                    }
                  # ...
                  + S3                           = {
                      + Properties = {
                          + Description = "An output exported from Terraform, made available for CloudFormation"
                          + Name        = {
                              + "Fn::Sub" = [
                                  + "/cloudformation/${StackName}/S3",
                                  + {
                                      + StackName = {
                                          + Ref = "AWS::StackName"
                                        }
                                    },
                                ]
                            }
                          + Type        = "String"
                          + Value       = "pl-7da54014"
                        }
                      + Type       = "AWS::SSM::Parameter"
                    }
                }
            }
        )
    }

Plan: 2 to add, 0 to change, 0 to destroy.
aws_cloudformation_stack.parameters: Creating...
aws_cloudformation_stack.outputs: Creating...
aws_cloudformation_stack.parameters: Still creating... [10s elapsed]
aws_cloudformation_stack.outputs: Still creating... [10s elapsed]
aws_cloudformation_stack.outputs: Creation complete after 11s [id=arn:aws:cloudformation:ca-central-1:621253221781:stack/aws-cfn-using-outputs-from-terraform-outputs/2d5fb9d0-2353-11ee-ae9d-02b5bcc396aa]
aws_cloudformation_stack.parameters: Creation complete after 11s [id=arn:aws:cloudformation:ca-central-1:621253221781:stack/aws-cfn-using-outputs-from-terraform-outputs-params/2d5e3330-2353-11ee-97a3-06fcf53db3b8]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

The two CloudFormation stacks will be provisioned which look something like:

```text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                                                                            DescribeStacks                                                                                                                                             |
+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
||                                                                                                                                               Stacks                                                                                                                                                ||
|+----------------------------------+------------------+------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------+-------------------+|
||           CreationTime           | DisableRollback  | EnableTerminationProtection  |                                                                  StackId                                                                   |                   StackName                   |    StackStatus    ||
|+----------------------------------+------------------+------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------+-------------------+|
||  2023-07-15T21:04:24.661000+00:00|  False           |  False                       |  arn:aws:cloudformation:ca-central-1:621253221781:stack/aws-cfn-using-outputs-from-terraform-outputs/2d5fb9d0-2353-11ee-ae9d-02b5bcc396aa  |  aws-cfn-using-outputs-from-terraform-outputs |  CREATE_COMPLETE  ||
|+----------------------------------+------------------+------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------+-------------------+|
|||                                                                                                                                         DriftInformation                                                                                                                                          |||
||+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------+||
|||  StackDriftStatus                                                                                                                                                   |  NOT_CHECKED                                                                                                                |||
||+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------+||
|||                                                                                                                                              Outputs                                                                                                                                              |||
||+--------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------+----------------------------------------+||
|||                          Description                         |                                                            ExportName                                                              |                      OutputKey                       |              OutputValue               |||
||+--------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------+----------------------------------------+||
|||  An output exported from Terraform                           |  aws-cfn-using-outputs-from-terraform-outputs-GlobalCloudfrontOriginfacing                                                         |  GlobalCloudfrontOriginfacing                        |  pl-38a64351                           |||
|||  An output exported from Terraform                           |  aws-cfn-using-outputs-from-terraform-outputs-S3                                                                                   |  S3                                                  |  pl-7da54014                           |||
|||  An output exported from Terraform                           |  aws-cfn-using-outputs-from-terraform-outputs-MyVariable                                                                           |  MyVariable                                          |  ABC123                                |||
|||  An output exported from Terraform                           |  aws-cfn-using-outputs-from-terraform-outputs-Dynamodb                                                                             |  Dynamodb                                            |  pl-4ea54027                           |||
|||  An output exported from Terraform                           |  aws-cfn-using-outputs-from-terraform-outputs-GlobalGroundstation                                                                  |  GlobalGroundstation                                 |  pl-08a6a3685cc410c2d                  |||
||+--------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------+----------------------------------------+||
```

With the stacks provisioned, it is posisble to deploy the stack responsbile for importing them. 

You can run the following command:

```bash
make cfn-props
```

This will yield a CloudFormation stack that imports the outputs from the CloudFormation stacks of `aws-cfn-using-outputs-from-terraform-outputs` and `aws-cfn-using-outputs-from-terraform-outputs-params`. For the imported outputs from the CloudFormation outputs, it is no longer possible to update the values from Terraform, as CloudFormation does not allow in-use exports to be updated in-place. This will error with the following:

```text
update: failed to update CloudFormation stack (UPDATE_ROLLBACK_COMPLETE): []

# From the CloudFormation events view:
#   Export aws-cfn-using-outputs-from-terraform-outputs-GlobalGroundstation cannot be updated as it is in use by aws-cfn-using-outputs-from-terraform
```

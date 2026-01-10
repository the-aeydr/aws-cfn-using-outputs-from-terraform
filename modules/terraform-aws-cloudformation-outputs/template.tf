locals {
  template_outputs = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"

    Resources = {
      "WaitHandle${sha256(jsonencode(local.outputs))}" = {
        Type = "AWS::CloudFormation::WaitConditionHandle"
      }
    }

    Outputs = {
      for key, value in local.outputs : key => {
        Value       = value
        Description = "An output exported from Terraform"
        Export = {
          Name = {
            "Fn::Sub": "$${AWS::StackName}-${key}"
          }
        }
      }
    }
  })
}

locals {
  template_parameters = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"

    Resources = {
      for key, value in local.outputs : key => {
        Type = "AWS::SSM::Parameter",
        Properties = {
          Name = {
            "Fn::Sub" : [
              "/cloudformation/$${StackName}/${key}",
              {
                StackName = {
                  Ref = "AWS::StackName"
                }
              }
            ]
          },
          Description = "An output exported from Terraform, made available for CloudFormation"
          Type        = "String"
          Value       = value
        }
      }
    }

    Outputs = {
      for key, _ in local.outputs : key => {
        Description = "The name of a parameter store entry that contains a value exported from Terraform"
        Value = {
          "Ref" : key
        }
        Export = {
          Name = {
            "Fn::Sub": "$${AWS::StackName}-${key}"
          }
        }
      }
    }
  })
}

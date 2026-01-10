data "aws_region" "current" {}

data "aws_ec2_managed_prefix_lists" "aws_managed_lists" {}

data "aws_ec2_managed_prefix_list" "aws_managed_list" {
  count = length(data.aws_ec2_managed_prefix_lists.aws_managed_lists.ids)
  id    = tolist(data.aws_ec2_managed_prefix_lists.aws_managed_lists.ids)[count.index]
}

locals {
  outputs = merge({
    "MyVariable" : "ABC123",
    }, {
    # A rather complicated set of functions that are intended to transform a domain-based
    # name of a prefix list into a title case string for the output. In practice, this
    # should rely on something less _finicky_
    #
    #  com.amazonaws.global.groundstation => GlobalGroundstation
    for prefix in data.aws_ec2_managed_prefix_list.aws_managed_list : join("", [for elem in split(".", replace(trimprefix(prefix.name, "com.amazonaws."), "${data.aws_region.current.name}.", "")) : title(replace(elem, "-", ""))]) => prefix.id
  })
}

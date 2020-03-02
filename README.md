# README
What I have in this Terraform example is nothing special; it's spins up a simple VPC with 2 subnets (1 public, 1 private) and then creates an autoscaling group which will spin up an EC2 instance in the private subnet.  What I want to draw your attention to is [this line](https://github.com/Neutrollized/terraform-aws-with-amd/blob/master/main.tf#L160) where I set my [instance_type](https://aws.amazon.com/ec2/instance-types/) and you will notice that it's `t3a.medium` -- so where's the `a` come from and what does it mean?

Given the name of this repo, you can probably surmise that the `a` stands for AMD.  At the time of writing, the AWS EC2 instances that you launch with the `a` feature [AMD's EPYC processors](https://aws.amazon.com/ec2/amd/).  Why should you care?  Well, this little extra `a` can save you 10% or more on your AWS EC2 instance costs with no drawbacks.

## Migration Barriers
For the majority of the use cases out there, there shouldn't be any barriers<sup>**</sup>.  Honestly, if you changed the `t3a.medium` to `t3.medium`, you'd be spinning up another Ubuntu server with the same CPU core count and memory sizing.  The only difference is what's powering it.

I find that a lot of people tend to think that differences between Intel and AMD is like Windows and Linux -- what works in the former won't work for the latter (generally not out of the box anyway).  The comparison I would like to draw is more like: gas vs electric vehicles.  If you think of the vehicle itself as the server and the driver is the end user, then the CPU is the engine.  While the architecture of the engine itself is different, it still has gears and powers the vehicle and is measured by how much horsepower it has and how much torque it produces.  From a driver perspective, nothing is different; you still control the 4 wheels of your vehicle with the steering wheel and gas & brake pedals.

If you pay attention to how various Linux packages or OS ISOs are named, you might notice that `x86_64` and `amd64` are used interchangeably and that's because it was actually AMD that invented the 64-bit processor architecture (hence the name **AMD64**) and it was in fact Intel that adopted AMD's ISA as an extension of their own x86 processor line (hence the name **x86_64**)


<sub><sup>**</sup> - There are code/apps/libraries out there that are compiled with flags and will only produce code for a certain kind of CPU.  Yes, I'm referring mainly to Gentoo linux and if you want to read into the details of it, you can do so [here](https://wiki.gentoo.org/wiki/GCC_optimization).</sub>

## Benefits
In terms of performance, I have seen no differences between equivalent Intel-backed and AMD-backed EC2 instances (i.e. t3.medium vs t3a.medium, or r5.xlarge vs r5a.xlarge).  I draw this observation both from personal use as well as "enterprise" production workloads that we run at work.

From a cost perspective, we see a healthy dose of savings as we run a large number of clusters and EC2 instances, which I can now say are powered by AMD as we've migrated away from Intel.

There are some hidden benefits for moving towards the AMD EPYCs as well.  As their architecture is different, they've been less impacted by the string of CPU vulnerabilities that has popped up recently such as Spectre, Meltdown, ZombieLoad, etc.  Something as simple as being on the right CPU can reduce a lot of potential headaches, so when my directors/VPs what not ask me if we have have anything to mitigate *[insert new CPU vulnerability here]*, my answer lately has just been: "We're safe.  AMD's not impacted."  and what a wonderful feeling that is...

When there's an arms race between two of largest CPU chip makers in the world, it's the consumers that ultimately win.

# TL;DR
If you already manage your AWS infrastructure with infrastructure as code -- whether that's [Terraform](https://www.terraform.io/) or AWS' CloudFormation -- you should consider dropping that `a` in your code and give these AMD EPYC-backed EC2 instances a whirl.  You just might be pleasantly surprised.

### Additional notes 
In practice, for the `aws_launch_configuration`, some of the other arguments that you should have in there are (IMHO) `key_name` and `security_groups` at the very least so that when the instance is launched it will have all the correct firewall rules and public keys in place for the user to login with without additional (manual) configuration.


### `terraform plan` output
```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.aws_availability_zones.zones: Refreshing state...
data.aws_ami.ubuntu: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_autoscaling_group.ec2_asg
      id:                                          <computed>
      arn:                                         <computed>
      availability_zones.#:                        <computed>
      default_cooldown:                            <computed>
      desired_capacity:                            <computed>
      force_delete:                                "false"
      health_check_grace_period:                   "300"
      health_check_type:                           <computed>
      launch_configuration:                        "${aws_launch_configuration.asg_conf.name}"
      load_balancers.#:                            <computed>
      max_size:                                    "2"
      metrics_granularity:                         "1Minute"
      min_size:                                    "1"
      name:                                        "terraform-test-asg-example"
      protect_from_scale_in:                       "false"
      service_linked_role_arn:                     <computed>
      tags.#:                                      "1"
      tags.0.%:                                    "3"
      tags.0.key:                                  "Name"
      tags.0.propagate_at_launch:                  "1"
      tags.0.value:                                "terraform-test-node-a"
      target_group_arns.#:                         <computed>
      vpc_zone_identifier.#:                       <computed>
      wait_for_capacity_timeout:                   "10m"

  + aws_eip.nat[0]
      id:                                          <computed>
      allocation_id:                               <computed>
      association_id:                              <computed>
      domain:                                      <computed>
      instance:                                    <computed>
      network_interface:                           <computed>
      private_dns:                                 <computed>
      private_ip:                                  <computed>
      public_dns:                                  <computed>
      public_ip:                                   <computed>
      public_ipv4_pool:                            <computed>
      vpc:                                         "true"

  + aws_eip.nat[1]
      id:                                          <computed>
      allocation_id:                               <computed>
      association_id:                              <computed>
      domain:                                      <computed>
      instance:                                    <computed>
      network_interface:                           <computed>
      private_dns:                                 <computed>
      private_ip:                                  <computed>
      public_dns:                                  <computed>
      public_ip:                                   <computed>
      public_ipv4_pool:                            <computed>
      vpc:                                         "true"

  + aws_internet_gateway.nomad_vpc_igw
      id:                                          <computed>
      owner_id:                                    <computed>
      tags.%:                                      "1"
      tags.Name:                                   "terraform-test-igw"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_launch_configuration.asg_conf
      id:                                          <computed>
      arn:                                         <computed>
      associate_public_ip_address:                 "false"
      ebs_block_device.#:                          <computed>
      ebs_optimized:                               <computed>
      enable_monitoring:                           "true"
      image_id:                                    "ami-064efdb82ae15e93f"
      instance_type:                               "t3a.medium"
      key_name:                                    <computed>
      name:                                        <computed>
      name_prefix:                                 "terraform-lc-example-"
      root_block_device.#:                         <computed>

  + aws_main_route_table_association.main
      id:                                          <computed>
      original_route_table_id:                     <computed>
      route_table_id:                              "${aws_route_table.nomad_vpc_main_rt.id}"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_nat_gateway.ngw[0]
      id:                                          <computed>
      allocation_id:                               "${element(aws_eip.nat.*.id, count.index)}"
      network_interface_id:                        <computed>
      private_ip:                                  <computed>
      public_ip:                                   <computed>
      subnet_id:                                   "${element(aws_subnet.public.*.id, count.index)}"

  + aws_nat_gateway.ngw[1]
      id:                                          <computed>
      allocation_id:                               "${element(aws_eip.nat.*.id, count.index)}"
      network_interface_id:                        <computed>
      private_ip:                                  <computed>
      public_ip:                                   <computed>
      subnet_id:                                   "${element(aws_subnet.public.*.id, count.index)}"

  + aws_route_table.nomad_vpc_main_rt
      id:                                          <computed>
      owner_id:                                    <computed>
      propagating_vgws.#:                          <computed>
      route.#:                                     "1"
      route.~3142594375.cidr_block:                "0.0.0.0/0"
      route.~3142594375.egress_only_gateway_id:    ""
      route.~3142594375.gateway_id:                "${aws_internet_gateway.nomad_vpc_igw.id}"
      route.~3142594375.instance_id:               ""
      route.~3142594375.ipv6_cidr_block:           ""
      route.~3142594375.nat_gateway_id:            ""
      route.~3142594375.network_interface_id:      ""
      route.~3142594375.transit_gateway_id:        ""
      route.~3142594375.vpc_peering_connection_id: ""
      tags.%:                                      "1"
      tags.Name:                                   "terraform-main-rt"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_route_table.nomad_vpc_ngw_rt[0]
      id:                                          <computed>
      owner_id:                                    <computed>
      propagating_vgws.#:                          <computed>
      route.#:                                     "1"
      route.~1668667102.cidr_block:                "0.0.0.0/0"
      route.~1668667102.egress_only_gateway_id:    ""
      route.~1668667102.gateway_id:                "${element(aws_nat_gateway.ngw.*.id, count.index)}"
      route.~1668667102.instance_id:               ""
      route.~1668667102.ipv6_cidr_block:           ""
      route.~1668667102.nat_gateway_id:            ""
      route.~1668667102.network_interface_id:      ""
      route.~1668667102.transit_gateway_id:        ""
      route.~1668667102.vpc_peering_connection_id: ""
      tags.%:                                      "1"
      tags.Name:                                   "terraform-a-rt"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_route_table.nomad_vpc_ngw_rt[1]
      id:                                          <computed>
      owner_id:                                    <computed>
      propagating_vgws.#:                          <computed>
      route.#:                                     "1"
      route.~1668667102.cidr_block:                "0.0.0.0/0"
      route.~1668667102.egress_only_gateway_id:    ""
      route.~1668667102.gateway_id:                "${element(aws_nat_gateway.ngw.*.id, count.index)}"
      route.~1668667102.instance_id:               ""
      route.~1668667102.ipv6_cidr_block:           ""
      route.~1668667102.nat_gateway_id:            ""
      route.~1668667102.network_interface_id:      ""
      route.~1668667102.transit_gateway_id:        ""
      route.~1668667102.vpc_peering_connection_id: ""
      tags.%:                                      "1"
      tags.Name:                                   "terraform-b-rt"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_route_table_association.rtb_assoc_ngw_private[0]
      id:                                          <computed>
      route_table_id:                              "${element(aws_route_table.nomad_vpc_ngw_rt.*.id, count.index)}"
      subnet_id:                                   "${element(aws_subnet.private.*.id, count.index)}"

  + aws_route_table_association.rtb_assoc_ngw_private[1]
      id:                                          <computed>
      route_table_id:                              "${element(aws_route_table.nomad_vpc_ngw_rt.*.id, count.index)}"
      subnet_id:                                   "${element(aws_subnet.private.*.id, count.index)}"

  + aws_subnet.private[0]
      id:                                          <computed>
      arn:                                         <computed>
      assign_ipv6_address_on_creation:             "false"
      availability_zone:                           "ca-central-1a"
      availability_zone_id:                        <computed>
      cidr_block:                                  "10.100.10.0/24"
      ipv6_cidr_block:                             <computed>
      ipv6_cidr_block_association_id:              <computed>
      map_public_ip_on_launch:                     "false"
      owner_id:                                    <computed>
      tags.%:                                      "3"
      tags.Name:                                   "terraform-private-a"
      tags.env:                                    "test"
      tags.subnet_type:                            "private"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_subnet.private[1]
      id:                                          <computed>
      arn:                                         <computed>
      assign_ipv6_address_on_creation:             "false"
      availability_zone:                           "ca-central-1b"
      availability_zone_id:                        <computed>
      cidr_block:                                  "10.100.11.0/24"
      ipv6_cidr_block:                             <computed>
      ipv6_cidr_block_association_id:              <computed>
      map_public_ip_on_launch:                     "false"
      owner_id:                                    <computed>
      tags.%:                                      "3"
      tags.Name:                                   "terraform-private-b"
      tags.env:                                    "test"
      tags.subnet_type:                            "private"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_subnet.public[0]
      id:                                          <computed>
      arn:                                         <computed>
      assign_ipv6_address_on_creation:             "false"
      availability_zone:                           "ca-central-1a"
      availability_zone_id:                        <computed>
      cidr_block:                                  "10.100.254.0/25"
      ipv6_cidr_block:                             <computed>
      ipv6_cidr_block_association_id:              <computed>
      map_public_ip_on_launch:                     "false"
      owner_id:                                    <computed>
      tags.%:                                      "2"
      tags.Name:                                   "terraform-public-a"
      tags.env:                                    "test"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_subnet.public[1]
      id:                                          <computed>
      arn:                                         <computed>
      assign_ipv6_address_on_creation:             "false"
      availability_zone:                           "ca-central-1b"
      availability_zone_id:                        <computed>
      cidr_block:                                  "10.100.254.128/25"
      ipv6_cidr_block:                             <computed>
      ipv6_cidr_block_association_id:              <computed>
      map_public_ip_on_launch:                     "false"
      owner_id:                                    <computed>
      tags.%:                                      "2"
      tags.Name:                                   "terraform-public-b"
      tags.env:                                    "test"
      vpc_id:                                      "${aws_vpc.vpc.id}"

  + aws_vpc.vpc
      id:                                          <computed>
      arn:                                         <computed>
      assign_generated_ipv6_cidr_block:            "false"
      cidr_block:                                  "10.100.0.0/16"
      default_network_acl_id:                      <computed>
      default_route_table_id:                      <computed>
      default_security_group_id:                   <computed>
      dhcp_options_id:                             <computed>
      enable_classiclink:                          <computed>
      enable_classiclink_dns_support:              <computed>
      enable_dns_hostnames:                        "true"
      enable_dns_support:                          "true"
      instance_tenancy:                            "default"
      ipv6_association_id:                         <computed>
      ipv6_cidr_block:                             <computed>
      main_route_table_id:                         <computed>
      owner_id:                                    <computed>
      tags.%:                                      "2"
      tags.Name:                                   "terraform-test-vpc"
      tags.env:                                    "test"


Plan: 18 to add, 0 to change, 0 to destroy.
```

### Disclaimer
I'm not an employee of nor am I affiliated in any way with AMD -- this repo is to draw awareness to (better) options outside of the default Intel-backed instances :)

AWS IaC with Terraform: Modules
Lab Description
In this lab, you will refactor your existing Terraform configuration into modular components. This practice enhances code reusability, maintainability, and organization by separating resources into logical groups. You'll create modules for network infrastructure, network security, and for application deployment behind a load balancer.

Common Task Requirements
•	Do not define the backend in the configuration; Terraform will use the local backend by default.
•	Avoid the usage of the local-exec provisioner.
•	The use of the prevent_destroy lifecycle attribute is prohibited.
•	Use versions.tf to define the required versions of Terraform and its providers.
•	Define the Terraform required_version as >= 1.5.7.
•	All variables must include valid descriptions and type definitions, and they should only be defined in variables.tf.
•	Resource names provided in tasks should be defined via variables or generated dynamically/concatenated (e.g., in locals using Terraform functions). Avoid hardcoding in resource definitions or using the default property for variables.
•	Configure all non-sensitive input parameter values in terraform.tfvars.
•	Outputs must include valid descriptions and should only be defined in outputs.tf.
•	Ensure TF configuration is clean and correctly formatted. Use the terraform fmt command to rewrite Terraform configuration files into canonical format and style.

Task Resources
Network Module Resources
•	VPC named cmtr-k5vl9gpq-vpc with a CIDR block of 10.10.0.0/16
•	Subnet cmtr-k5vl9gpq-subnet-public-a in AZ us-east-1a with CIDR 10.10.1.0/24
•	Subnet cmtr-k5vl9gpq-subnet-public-b in AZ us-east-1b with CIDR 10.10.3.0/24
•	Subnet cmtr-k5vl9gpq-subnet-public-c in AZ us-east-1c with CIDR 10.10.5.0/24
•	Internet Gateway cmtr-k5vl9gpq-igw and attach it to the VPC cmtr-k5vl9gpq-vpc
•	Routing table cmtr-k5vl9gpq-rt to associate the Internet Gateway with the public subnets, enabling outbound internet traffic from these subnets

Network Security Module Resources
1.	SSH Security Group
- Name: cmtr-k5vl9gpq-ssh-sg
- Ingress Rules:
o	Allow SSH (port 22/tcp) from allowed ip-range: ["18.153.146.156/32", "YOUR_PUBLIC_IP/32"]
2.	Public HTTP Security Group
- Name: cmtr-k5vl9gpq-public-http-sg
- Ingress Rules:
o	Allow HTTP (port 80/tcp) from allowed ip-range: ["18.153.146.156/32", "YOUR_PUBLIC_IP/32"]
3.	Private HTTP Security Group
- Name: cmtr-k5vl9gpq-private-http-sg
- Ingress Rules (use security group instead of CIDR blocks):
o	Allow HTTP (port 80/tcp) from Public HTTP Security Group (cmtr-k5vl9gpq-public-http-sg)
Application Module Resources
1.	Launch Template (cmtr-k5vl9gpq-template): Configures the settings for launching compute instances.
•	Instance type: t3.micro
•	Security Groups: cmtr-k5vl9gpq-ssh-sg and cmtr-k5vl9gpq-private-http-sg
•	Network interface setting: delete_on_termination=true
•	Add the start-up bash script to the user_data field:
Getting Compute Instance Metadata:
COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid |tr '[:upper:]' '[:lower:]')
COMPUTE_INSTANCE_ID=$(replace this text with request instance id from metadata e.g. using curl. Note that COMPUTE_INSTANCE_ID may have different name on different providers.)
Creates a simple HTML web page, which displays this instance-specific information:
This message was generated on instance {COMPUTE_INSTANCE_ID} with the following UUID {COMPUTE_MACHINE_UUID}

2.	Auto Scaling Group (cmtr-k5vl9gpq-asg): Dynamically manages compute instances behind the Application Load Balancer.
•	Desired capacity: 2
•	Minimum size: 2
•	Maximum size: 2
•	Add a lifecycle configuration block to ignore changes to load_balancers and target_group_arns.

3.	Application Load Balancer (cmtr-k5vl9gpq-lb): Distributes incoming traffic across instances in the Auto Scaling Group.
•	Listener: HTTP protocol on port 80
•	Attach the Load Balancer to the Auto Scaling Group using aws_autoscaling_attachment.
•	Assign security group cmtr-k5vl9gpq-public-http-sg.

Objectives
1.	Create a directory structure for your modules:
   ~/modules/
   ├── network/
   ├── network_security/
   └── application/
   
Notes: My root folder is /home/dansanto/Courses/Terraform/AWS_IaC_with_Terraform_Modules1

2.	For each module, create the following files:
•	main.tf - Contains the resource definitions
•	variables.tf - Defines input variables for the module
•	outputs.tf - Defines the outputs from the module

3.	Network Module:
•	Add VPC, subnets, internet gateway, and routing resources to this module
•	Parameterize CIDR blocks, region, and resource naming
•	Export VPC ID and subnet IDs as outputs
•	In the variables.tf file, define allowed_ip_range - list of IP address range for secure access.

4.	Network Security Module:
•	Add security groups and security group rules to this module
•	Parameterize VPC ID and IP ranges for security rules
•	Export security group IDs as outputs

5.	Application Module:
•	Add launch template, autoscaling group, load balancer, and related resources
•	Parameterize subnet IDs, security group IDs, and instance properties
•	Export load balancer DNS name as output

6.	Update your root configuration to use the network, network security, and application modules. In your terraform.tfvars file, set allowed_ip_range = ["18.153.146.156/32", "YOUR_PUBLIC_IP/32"]. Example: allowed_ip_range = ["18.153.146.156/32", "203.0.113.25/32"]

7.	Validate and format your Terraform code:
•	Run terraform validate to ensure the configuration is correct
•	Run terraform fmt to ensure your code follows canonical formatting and style
•	Perform these checks for each module and root configuration
•	Run terraform plan to preview infrastructure changes

Task Verification
1.	Ensure all modules have been properly structured with appropriate files
2.	Verify that the root configuration successfully uses the network, network security, and application modules
3.	Check that terraform plan shows no unexpected changes when run after applying
4.	Verify all resources exist in AWS
5.	Confirm that the application is still functioning as expected:
- Instances are running behind the load balancer
- Web server is serving the expected content

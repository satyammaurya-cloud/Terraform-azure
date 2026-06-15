# Terraform Notes

## Table of Contents
- [What Is Terraform?](#what-is-terraform)
- [Benefits of Infrastructure-as-Code (IaC)](#benefits-of-infrastructure-as-code-iac)
- [Basic Terraform Folder Structure](#basic-terraform-folder-structure)
- [Important Terraform Commands](#important-terraform-commands)
- [State File](#state-file)
- [Data Sources](#data-sources)
- [Terraform Import](#terraform-import)
- [Meta-Arguments](#meta-arguments)
  - [depends_on](#depends_on)
  - [count](#count)
  - [for_each](#for_each)
  - [Multi Provider](#multi-provider)
  - [lifecycle](#lifecycle)
- [Locals](#locals)
- [Provisioners](#provisioners)
- [Modules](#modules)
- [Connection Block](#connection-block)
- [Output Values](#output-values)
- [Conditions / Validation](#conditions--validation)

---

## What Is Terraform?

Terraform is an **IaC (Infrastructure as Code)** tool, used primarily by DevOps teams to automate various infrastructure tasks. The provisioning of cloud resources, for instance, is one of the main use cases of Terraform. It's a **cloud-agnostic, open-source** provisioning tool written in the Go language and created by **HashiCorp**.

Terraform allows you to describe your complete infrastructure in the form of code. Even if your servers come from different providers such as AWS or Azure, Terraform helps you build and manage these resources in parallel across providers.

---

## Benefits of Infrastructure-as-Code (IaC)

IaC replaces standard operating procedures and manual effort required for IT resource management with lines of code. Instead of manually configuring cloud nodes or physical hardware, IaC automates the process of infrastructure management through source code.

| Benefit | Description |
|---|---|
| **Speed and Simplicity** | Eliminates manual processes, accelerating delivery and management lifecycles. Spin up entire infrastructure by running a script. |
| **Team Collaboration** | Team members can collaborate using tools like GitHub, same as regular application code. |
| **Error Reduction** | Minimizes probability of errors or deviations when provisioning infrastructure. |
| **Disaster Recovery** | Re-run scripts to provision the exact same infrastructure again rapidly. |
| **Enhanced Security** | Removes many security risks associated with human error through automation. |

---

## Basic Terraform Folder Structure

```
projectname/
    |-- provider.tf
    |-- version.tf
    |-- backend.tf
    |-- main.tf
    |-- variables.tf
    |-- terraform.tfvars
    |-- outputs.tf
```

### Recommended File Naming Convention

| File | Purpose |
|---|---|
| `provider.tf` | Contains the terraform block and provider block |
| `data.tf` | Contains all data sources |
| `variables.tf` | Contains all defined variables |
| `locals.tf` | Contains all local variables |
| `output.tf` | Contains all output resources |

> **Note:** Terraform does not mandate any specific filename structure. Filenames do not matter to Terraform — it only requires a directory of `.tf` files.

---

## Important Terraform Commands

### Version
```bash
terraform -version        # Shows terraform version installed
```

### Initialize Infrastructure
```bash
terraform init                  # Initialize a working directory
terraform init -input=true      # Ask for input if necessary
terraform init -lock=false      # Disable locking of state files
```

### Plan & Apply
```bash
terraform plan                  # Creates an execution plan (dry run)
terraform apply                 # Executes changes to the actual environment
terraform apply -auto-approve   # Apply changes without being prompted
terraform destroy -auto-approve # Destroy/cleanup without being prompted
```

### Terraform Workspaces
```bash
terraform workspace new <name>     # Create a new workspace and select it
terraform workspace select <name>  # Select an existing workspace
terraform workspace list           # List the existing workspaces
terraform workspace show           # Show the name of the current workspace
terraform workspace delete <name>  # Delete an empty workspace
```

### Terraform Import
```bash
terraform import aws_instance.example <instance-id>
# Example:
terraform import aws_instance.example i-abcd1234
```

---

## State File

### What Is State and Why Is It Important?

> *"Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures."*

The `terraform.tfstate` file maps various resource metadata to actual resource IDs so that Terraform knows what it is managing.

### Remote State

> *"By default, Terraform stores state locally in a file named `terraform.tfstate`. When working with Terraform in a team, use of a local file makes Terraform usage complicated because each user must make sure they always have the latest state data before running Terraform."*

With **remote state**, Terraform writes state data to a remote data store, which can then be shared between all members of a team.

### State Lock

> *"If supported by your backend, Terraform will lock your state for all operations that could write state. This prevents others from acquiring the lock and potentially corrupting your state."*

State locking happens automatically on all operations that could write state. You can disable it with the `-lock` flag (not recommended).

### Setting Up an S3 Backend

**Step 1:** Create S3 bucket and DynamoDB table resources.

```hcl
# S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "sample"
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

**Step 2:** Create `backend.tf` with the following configuration.

```hcl
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "sample"
    dynamodb_table = "terraform-state-lock-dynamo"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
```

---

## Data Sources

### What Is a Data Source?

Data sources in Terraform provide information about objects rather than creating them. They allow fetching data about infrastructure components' configuration from cloud provider APIs.

> When you refer to a resource using a data source, it **won't create** the resource. Instead, it gets information about that resource to use in further configuration.

### Example 1: Using Existing VPC and Subnet

**`provider.tf`**
```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "your_access_key"
  secret_key = "your_secret_key"  # Keys can also be loaded from ~/.aws folder
}
```

**`demo_datasource.tf`**
```hcl
data "aws_vpc" "vpc" {
  id = vpc_id
}

data "aws_subnet" "subnet" {
  id = subnet_id
}

resource "aws_security_group" "sg" {
  name   = "sg"
  vpc_id = data.aws_vpc.vpc.id  # Calling existing VPC via data source

  ingress = [
    {
      cidr_blocks     = ["0.0.0.0/0"]
      description     = ""
      from_port       = 22
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 22
    }
  ]

  egress = [
    {
      cidr_blocks     = ["0.0.0.0/0"]
      description     = ""
      from_port       = 0
      protocol        = "-1"
      security_groups = []
      self            = false
      to_port         = 0
    }
  ]
}

resource "aws_instance" "dev" {
  ami             = data.aws_ami.amzlinux.id
  instance_type   = "t2.micro"
  subnet_id       = data.aws_subnet.dev.id
  security_groups = [data.aws_security_group.dev.id]

  tags = {
    Name = "DataSource-Instance"
  }
}
```

### Example 2: Fetching Latest AMI via Data Source

```hcl
data "aws_ami" "amzlinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
```

---

## Terraform Import

### Why Use Terraform Import?

Terraform Import helps bring **pre-existing cloud resources** under Terraform management. It reads real-world infrastructure and updates the state so that future updates can be applied via IaC.

> **Note:** The import functionality updates state locally but does **not** create the corresponding configuration automatically.

### Step-by-Step Import Guide (EC2 Instance)

**1. Prepare the EC2 Instance**

Example EC2 details:
- Name: `MyVM`
- Instance ID: `i-0b9be609418aa0609`
- Type: `t2.micro`
- VPC ID: `vpc-1827ff72`

**2. Create `main.tf` with Provider Configuration**

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

Run `terraform init` to initialize.

**3. Write Stub Config for the Resource**

```hcl
resource "aws_instance" "myvm" {
  ami           = "unknown"   # To be updated from state file
  instance_type = "unknown"   # To be updated from state file
}
```

**4. Run the Import Command**

```bash
terraform import aws_instance.myvm i-0b9be609418aa0609
```

**5. Observe the State File and Plan Output**

Run `terraform plan` to see the diff between your config and the imported state.

**6. Update Config to Avoid Replacement**

Update `ami` to the value shown in the plan output, then re-run `terraform plan`.

**7. Final Config with Zero Differences**

```hcl
resource "aws_instance" "myvm" {
  ami           = "ami-00f22f6155d6d92c5"
  instance_type = "t2.micro"

  tags = {
    "Name" = "MyVM"
  }
}
```

Once `terraform plan` shows **"No changes"**, the import is complete.

---

## Meta-Arguments

Meta-arguments are special arguments used with resource blocks and modules to control behavior or influence the infrastructure provisioning process.

| Meta-Argument | Description |
|---|---|
| `depends_on` | Specifies explicit dependencies between resources |
| `count` | Controls resource instantiation by setting number of instances |
| `for_each` | Creates multiple instances based on a map or set of strings |
| `lifecycle` | Defines lifecycle rules for resource updates, replacements, deletions |
| `provider` | Specifies the provider configuration for a resource |
| `provisioner` | Specifies actions to take on a resource after creation |
| `connection` | Defines connection details for remote execution |
| `variable` | Declares input variables |
| `output` | Declares output values |
| `locals` | Defines local values within configuration files |

---

### depends_on

Used to explicitly define dependencies that Terraform cannot automatically infer.

**Example 1: EC2 depends on S3**

```hcl
provider "aws" {}

resource "aws_s3_bucket" "example" {
  bucket = "qwertyuiopasdfg"
}

resource "aws_instance" "dev" {
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
  depends_on    = [aws_s3_bucket.example]  # EC2 only creates after S3 is created
}
```

**Example 2: EC2 depends on IAM Role**

```hcl
resource "aws_iam_policy" "example_policy" {
  name        = "example_policy"
  description = "Permissions for EC2"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "example_role" {
  name = "example_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = "examplerole"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "policy_attach" {
  name       = "example_policy_attachment"
  roles      = [aws_iam_role.example_role.name]
  policy_arn = aws_iam_policy.example_policy.arn
}

resource "aws_iam_instance_profile" "example_profile" {
  name = "example_profile"
  role = aws_iam_role.example_role.name
}

resource "aws_instance" "example_instance" {
  instance_type        = var.ec2_instance_type
  ami                  = var.image_id
  iam_instance_profile = aws_iam_instance_profile.example_profile.name
  depends_on           = [aws_iam_role.example_role]  # EC2 creates after IAM role
}
```

---

### count

Creates multiple instances of a resource. Use `count.index` (ranging from `0` to `count-1`) to uniquely identify each instance.

**Example 1: Simple count**

```hcl
resource "aws_instance" "myec2" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  count         = 2

  tags = {
    Name = "webec2-${count.index}"
  }
}
```

**Example 2: count with a list variable**

```hcl
variable "ami" {
  type    = string
  default = "ami-0440d3b780d96b29d"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sandboxes" {
  type    = list(string)
  default = ["sandbox_server_two", "sandbox_server_three"]
}

resource "aws_instance" "sandbox" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = length(var.sandboxes)

  tags = {
    Name = var.sandboxes[count.index]
  }
}
```

---

### for_each

Creates multiple resource instances based on a **map or set of strings**. More flexible than `count`.

- `each.key` — the map key or set member
- `each.value` — the map value

> **Note:** `for_each` cannot be used together with `count`.

**Example:**

```hcl
variable "ami" {
  type    = string
  default = "ami-0078ef784b6fa1ba4"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sandboxes" {
  type    = set(string)
  default = ["sandbox_one", "sandbox_two", "sandbox_three"]
}

resource "aws_instance" "sandbox" {
  ami           = var.ami
  instance_type = var.instance_type
  for_each      = var.sandboxes

  tags = {
    Name = each.value  # For a set, each.value and each.key are the same
  }
}
```

---

### Multi Provider

Use the `provider` meta-argument with an `alias` when managing resources across multiple regions or accounts.

**Example:**

```hcl
# Default provider (ap-south-1)
provider "aws" {
  region = "ap-south-1"
}

# Aliased provider (us-east-1)
provider "aws" {
  region = "us-east-1"
  alias  = "america"
}

resource "aws_s3_bucket" "test" {
  bucket = "del-hyd-naresh-it"
}

resource "aws_s3_bucket" "test2" {
  bucket   = "del-hyd-naresh-it-test2"
  provider = aws.america  # Uses aliased provider
}
```

---

### lifecycle

Controls how Terraform handles creation, modification, and destruction of resources.

**Example:**

```hcl
resource "aws_instance" "test" {
  ami               = "ami-0440d3b780d96b29d"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1b"

  tags = {
    Name = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

#### Lifecycle Options

| Option | Description |
|---|---|
| `create_before_destroy` | Creates the new resource before destroying the old one — reduces downtime |
| `prevent_destroy` | Prevents Terraform from accidentally destroying critical resources |
| `ignore_changes` | Ignores specified attribute changes made outside of Terraform |

**`create_before_destroy`**
```hcl
lifecycle {
  create_before_destroy = true
}
```

**`prevent_destroy`**
```hcl
lifecycle {
  prevent_destroy = true
}
```

**`ignore_changes` (specific attribute)**
```hcl
lifecycle {
  ignore_changes = [
    tags["department"]
  ]
}
```

**`ignore_changes` (all attributes)**
```hcl
lifecycle {
  ignore_changes = [all]
  # Terraform will never update the object but can still create or destroy it
}
```

---

## Locals

A local value assigns a name to an expression so you can use the name multiple times within a module. Useful for avoiding repetition.

> Local values are **not** set by user input or `.tfvars` files — they are set locally within the configuration.

**Example:**

```hcl
locals {
  bucket-name = "${var.layer}-${var.env}-bucket-hydnaresh"
}

resource "aws_s3_bucket" "demo" {
  bucket = local.bucket-name

  tags = {
    Name        = local.bucket-name
    Environment = var.env
  }
}
```

---

## Provisioners

Provisioners model specific actions on local or remote machines to prepare servers or other infrastructure objects for service.

> Terraform recommends using provisioners only as a **last resort** when behavior can't be represented in Terraform's declarative model.

### File Provisioner

Copies files or directories from the machine running `terraform apply` to the newly created resource.

```hcl
resource "aws_instance" "web" {
  # ...

  provisioner "file" {
    source      = "conf/myapp.conf"
    destination = "/etc/myapp.conf"
  }
}
```

### local-exec Provisioner

Invokes a local executable **on the machine running Terraform** after a resource is created.

```hcl
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}
```

### remote-exec Provisioner

Invokes a script **on the remote resource** after it is created. Requires a `connection` block and supports both SSH and WinRM.

```hcl
resource "aws_instance" "web" {
  # ...

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "touch file200",
      "echo hello from aws >> file200",
    ]
  }
}
```

---

## Modules

### What Are Terraform Modules?

Terraform modules are **reusable and encapsulated collections** of Terraform configurations. They simplify managing resources, making Terraform code more manageable and scalable.

### Benefits of Using Modules

| Benefit | Description |
|---|---|
| **Reusability** | Repurpose infrastructure configurations across projects and environments |
| **Abstraction** | Simplify resource creation; make config files more concise and understandable |
| **Encapsulation** | Isolate resources and dependencies; modify individual pieces without impacting others |
| **Versioning** | Track changes and update dependencies in an orderly manner |
| **Collaboration** | Share via Terraform Registry or private repositories to standardize configurations |

---

### Example 1: AWS VPC Module

**Directory Structure:**
```
modules/
  vpc/
    main.tf
    variables.tf
```

**`modules/vpc/main.tf`**
```hcl
resource "aws_vpc" "example" {
  cidr_block = var.cidr_block
  tags       = { Name = var.name }
}
```

**`modules/vpc/variables.tf`**
```hcl
variable "cidr_block" {
  description = "The CIDR block for the VPC."
}

variable "name" {
  description = "The name of the VPC."
}
```

**`main.tf` (calling the module)**
```hcl
module "my_vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "my-vpc"
}
```

---

### Example 2: AWS EC2 Instance Module

**Directory Structure:**
```
modules/
  ec2/
    main.tf
    variables.tf
```

**`modules/ec2/main.tf`**
```hcl
resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  tags = {
    Name = var.name
  }
}
```

**`modules/ec2/variables.tf`**
```hcl
variable "ami" {
  description = "The AMI ID for the EC2 instance."
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance."
}

variable "key_name" {
  description = "Key pair to associate with the EC2 instance."
}

variable "name" {
  description = "The name of the EC2 instance."
}
```

**`main.tf` (calling the module)**
```hcl
module "my_ec2" {
  source        = "./modules/ec2"
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = "subnet-01234567"
  key_name      = "my-key-pair"
  name          = "my-ec2-instance"
}
```

### Module Source from GitHub

```hcl
module "example" {
  source = "github.com/CloudTechDevOps/Terraform/root_modules"
}
```

---

## Connection Block

Describes how to access a remote resource. Can be nested within a resource or a provisioner.

```hcl
connection {
  type        = "ssh"
  user        = "ubuntu"         # Replace with appropriate username
  private_key = file("~/.ssh/id_rsa")
  host        = self.public_ip
}
```

> A `connection` block nested directly within a resource affects **all** of that resource's provisioners.

---

## Output Values

Output values make information about your infrastructure available on the command line, and can expose information for other Terraform configurations to use.

```hcl
output "instance_public_ip" {
  value     = aws_instance.test.public_ip
  sensitive = true
}

output "instance_id" {
  value = aws_instance.test.id
}

output "instance_public_dns" {
  value = aws_instance.test.public_dns
}

output "instance_arn" {
  value = aws_instance.test.arn
}
```

---

## Conditions / Validation

Use `validation` blocks inside variable declarations to restrict allowed values and provide helpful error messages.

```hcl
variable "aws_region" {
  description = "The region in which to create the infrastructure"
  type        = string
  nullable    = false
  default     = "change me"

  validation {
    condition     = var.aws_region == "us-west-2" || var.aws_region == "eu-west-1"
    error_message = "The variable 'aws_region' must be one of the following regions: us-west-2, eu-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

*Notes compiled for DevOps / Terraform learning reference.*

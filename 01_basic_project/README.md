# Understanding HashiCorp Terraform: The Basic Project

Welcome to the first project of the workshop. It is meant to get you up to speed.

## Terraform Background

HashiCorp Terraform [in its own words](https://www.terraform.io/intro/index.html):

*Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. Terraform codifies cloud APIs into declarative configuration files.*

*Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.*

*Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.*

Terraform is itself quite "minimal" and is expanded with the help of "providers". There are offical HashiCorp providers for all the major cloud companies (AWS, Azure, GCP, Oracle, Alibaba...) and the major on-prem/private cloud platforms like vSphere/vClouds and OpenStack. Hashicorp also maintains an official Kubernetes provider.

There is also a big community who are contributing their own so called "modules", which are ready-made applications written with a specific provider designed to address common use-cases.

Terraform is written in Go and it is possible to create a provider for literally any thing that accepts API commands. As an example, check out the [*Minecraft Provider*](https://github.com/scottwinkler/terraform-provider-minecraft) written by [Scott Wrinkler](https://www.youtube.com/watch?v=--iS_LH-5ls). 

## Terraform vs Cloud-specific IaC?

Terraform has become the standard for "cloud agnostic" IaC. AWS, as an example, has their own one called Amazon CloudFormation. While there are some advantages to using the cloud provider's own tool, particularly when it comes to managing the *state* of an orchestration, Terraform has its own list of advantages:
- It is cloud-agnostic, allowing you to mix and match different providers while using the same language syntax (HCL). 
- Cloud providers like AWS have a decentralized structure, where a team releases a service and its APIs to the public first, before the CloudFormation team are able to extend the IaC. Due to the open source community around Terraform, it is often able to make the new services available in Terraform faster than the cloud themselves. 

## Terraform Project Structure

A basic project can be divided in the following way:

- main.tf // call modules, locals and data-sources to create all resources
- variables.tf // contains declarations of variables used in main.tf
- outputs.tf // contains outputs from the resources created in main.tf
- terraform.tfstate // generated, contains the state of your infrastructure

Terraform evaluates ALL of the .tf files in a directory, so lines of code can be moved around. Instead of main.tf, you might have one s3.tf file for all of your AWS S3 buckets, policies, etc; and so on.

If your project comes very large you can abstract all the contents of a directory as a "module" and call on it from a root-directory. Then you can use your variables and outputs to insert and extract stateful information between modules.

Variables can be declared empty and be set when you run `terraform apply` (through a prompt), or they can be declared with a "default value". You can also specify certain conditions on them, like type. 

If you need to specifiy a LOT of variables, it can be convenient to use a variable definitions file, explicitly named terraform.tfvars or terraform.tfvars.json.


## State Management - "Backend"

Terraform tracks the state of your deployment/resources in a file called terraform.tfstate. By default it is stored locally, which can work OK if you are a single developer working from one machine.

But things can get very difficult if:
- someone else starts fiddling with the actual resources
- you are multiple people contributing to the same code-base
- you need to pass along sensitive secrets as part of the code

Terraform has something called "Backend" that deals with this. In addition to the aforementioned "local" backend, we have some examples:

- s3. The terraform.tfstate file is stored in an S3 bucket, while a DynamoDB table is used to lock/unlock access to the state file, preventing race conditions.

- Terraform Cloud & Enterprise: HashiCorp commercial application, how they make money off of Terraform. Terraform Enterprise is a self-hosted version of Terraform Cloud. The application helps teams use Terraform together, managing Terraform runs in a consistent and reliable environment. This includes giving easy access to shared state and secret data, as well as making it easy to handle access management.

- artifactory, azurerm, consul, cos, etcd, etcdv3, gcs, http, kubernetes, manta, oss, pg, swift, ...

- Refer to Terraform's [documentation page for backend services](https://www.terraform.io/docs/language/settings/backends/configuration.html).  

# Deploying with Terraform

Navigate to the basic_project directory: 

`cd basic_project`

Initialize the Terraform project:

`terraform init`

Deploy the Terraform resources:

`terraform apply`

It will first prompt you to give your name.  Then, It will provide you with the deployment plan, inform you what resources will be created and such and finally ask you to confirm.

Once Terraform has finished, wait a minute or two before visiting the IP-address provided as an output in the termianl window. Navigate to it (http NOT https) and you should be greeted.

If you want, you can use the SSH-key generated to access your machine:

```
chmod 400 [key name]
ssh -i [key name] ubuntu@[ip-address] 

```   

Once you are done, destroy the resources so you do not incurr any charges!

`terraform destroy`

## Run down of the code!

So what is going in in the files?

### variables.tf

Here we define four variables:
- region: Which region to deploy in. "eu-north-1" refers to Stockholm, "eu-west-1" Ireland, "us-north-1" N. Virginia and so on. Refer to AWS' documentation for this.

- instance_type: The type and size of the EC2 instance. In this case we have the t3.micro, so from the t3 family (3rd generation low cost, general burstable compute), micro-size (1 vCPU and 1 GiB memory). Cost is about $0.0104 per Hour (us-east-1, 2021-03-17).

- project: This is a variable I like to keep to insert into AWS resource tag names etc. It's a naming convention.

- your_name: All the other variables have default values, but not this one. I purposedly added this so you could experiance manually typing in a variable name. It is also used for naming (to separate you from other members of the workshop) and to show how Terraform can insert values into a string or files, e.g. like howe do for the installation script.


### outputs.tf

Resources created by Terraform will typically have values (id, names, URLs, etc) that might be of interest to other modules (if we were to run this directory as a module), or just you as the user.

In this case we are exposing the public ip-address.


### main.tf

- We first define the provider "aws" and the region we are going to operate in.

- We then get to the AWS EC2 instance (virtual machine). We can specify an Amazon Machine Image (AMI, the OS) directly, but the same OS (e.g. Ubuntu 20.04) might have different ids in different regions, so we use the data.aws_ami object to have Terraform search for the Ubuntu AMI and store it.

- We make use of the EC2's user_data field to insert an installation script for Apache2 on Ubuntu, with var.your_name to customize the html page the EC2 will be showing.

- We also have a bunch of network resources that we create. AWS creates "default VPCs" in each region to make it easier for you, but in this case we just create our own to further sandbox each workshop member's environment. We have the VPC (10.0.0.0/16), the specific subnet (10.0.0.0/24), the Internet Gateway for the VPC, the route table that routes requests in the network, and finally a Securty Group which is basically a firewall that we can manage from outside the EC2.  

- Regarding the Security Group, we expose the HTTP port 80 to the whole world, but the SSH port 20 only to one specific ip - yours! We use the data.http object to query ip.seeip.org and get the ip-adress of the machine deploying Terraform. Then we use chomp to get the body of the JSON response of the request and to enter it in as a cidr_block.

- In the final parts, we are generating the SSH key we will be using to access the EC2. Note that this is ONLY ok for testing, not for continuous use...


### apache_installation.sh.tpl

Our EC2 will run Ubuntu. Using AWS EC2's "user data" input, we will use the contents of this file to install the Apache2 web server.

Note that all user data files need to start with `#!/bin/bash`.

Also note that ${name} is a template variable Terraform. 


# **BEWARE**:

This code some issues which makes it totally inappropriate for production use.

### **SSH KEY and exposing sensitive data in terraform.tfstate...**
We are generating the key as part of our code, meaning that if you check out the terraform.tfstate file it will contain the private key and be exposing it for everyone to see. This is TOTALLY UNACCEPTABLE.

IF you need to have SSH access to your machines, please generate the keys as a separate step and then simply refer to the key by its name in your Terraform code. One way is to use the AWS management console to do this. 

It is also possible to do it using the AWS CLI, like so:

``` 
aws ec2 create-key-pair --key-name [KEYNAME] --query 'KeyMaterial' --output text > SS_EC2_key.pem
chmod 400 SS_EC2_key.pem
```  

And then, to delete:

```
aws ec2 delete-key-pair --key-name [KEYNAME]
rm [KEYNAME].pem

```

In production use we ideally want to keep the SSH port 22 closed completely in the security group.

### **The userdata field and Configuration as Code...**

In this code we made use of the fact that AWS offers a "userdata" field for its EC2 instance, i.e. code that will be run on creation. Since Terraform has abstracted everything, we can use this field to send an installation script for the Apache2 server.

For production use, it is recommend that you use a dedicated configuration management tool like Ansible, Chef, Puppet, etc. Use Terraform to provision the machines, and then use one of these tools to ensure that they are all configured properly.

HashiCorp also offers "Packer". Packer is a tool used for creating machine images. In this project, we have simply used Ubuntu and then user data to run some lines of code. With Packer, we could create so called "golden images" on AWS, that we can then have Terraform find and refer to when it creates the EC2 machines in the first place. These two can then be further supplemented with, for example, Ansible to manage existing servers (if needed).

Use the right tool for the right job. 



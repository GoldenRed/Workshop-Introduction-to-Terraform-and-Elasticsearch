# Workshop-Introduction-to-Terraform-and-Elasticsearch
Introduction to Terraform &amp; Elasticsearch - Workshop I held for Mirado Consulting.

## Description

Workshop held at Mirado Consulting, an introduction to Infrastructure-as-Code with Terraform and search with Elasticsearch.


# Preparations

Before the workshop can be run, the following steps need to be performed.

## Step 1.1: Get your AWS Credentials

We will be using Terraform to programmatically interact with AWS and provision resources.

Terraform relies on the AWS programmatic access credentials (Access Key + Secret Access Key).

Log into the AWS management console.

Navigate to: Users -> {your username} -> Security Credentials tab -> Under Access Key press Create Access Key.

In AWS each account can have 2 Access Keys simultaneously, the idea being that you can stagger the adoption of the new key pair, monitoring over time to see if the old key is still being used. If you already have a key from before, make the old one inactive and then delete it. Then, press Create Access Key and get the modal window. On it, download the CSV file containing the Access Key and Secret Access Key. Note that this is the only time AWS will provide you with the Secret Access Key, if you lose it now you have to re-create your key pair.



## Step 1.2: Installing the AWS CLI:

There are several ways of interacting with AWS:
- Using HTTP methods with the right headers
- Using the Management Console GUI
- Using AWS SDKs (Python, NodeJs, Go, C++, etc…) 
- Using the AWS CLI

(The latter 3 abstract away the 1st)

Terraform is written in Go and actually makes use of the AWS SDK for Go under the hood.

When you use it, it will need to have access to the Access Key and Secret Access Key. In order to avoid supplying Terraform with them in plaintext (or some other complicated method), we might as well go ahead and download the AWS CLI and configure it with our credentials. Terraform will be able to access it.

The instructions for downloading and installing the CLI can be found here: 
- Windows: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html
- Mac: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html
- Linux: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html 

Once you have successfully installed it, run:

`aws configure`

You will be prompted to enter your Access key, Secret Access key, region and your preferred output format (YAML or JSON). 

```
AWS Access Key ID: 
AWS Secret Access Key: 
Default region name [us-west-2]:
Default output format [None]:
```

Supply the first two values using the info in the .CSV file. For the region name, you can write “eu-north-1” (without citation marks). That is the designation for the “Stockholm” region, which in turn has 3 Availability Zones (massive data centers, located in Eskilstuna, Västerås and Katrineholm). For output format you can just press enter and not provide anything.

Regarding the regions, AWS has limits on how many EC2 instances (AWS Elastic Cloud Compute virtual machines) each account is allowed to deploy by default - around 20. Depending on how many people are in the workshop, some of you will be asked to pick some other region, e.g. eu-west-1 (Ireland, AWS’ oldest region in Europe). But we will be defining that explicitly in the Terraform code so you can all go with eu-north-1.

To test that you have setup things properly, run the following command:

`aws s3 ls`

This should return a list of the AWS Simple Storage Service (S3) “buckets” that have been created in the Mirado account.


## STEP 1.3: Installing Terraform

In this step we will install the Terraform CLI.

Follow the instructions on this page (up until the Quickstart Tutorial): https://learn.hashicorp.com/tutorials/terraform/install-cli

You can do a quick verification that things are working by running 

`terraform -help`

Then you can create a directory (call it whatever) and create the file main.tf with the following content:

```
provider "aws" {
    region = "eu-north-1"
}
```

Save and then run:

`terraform init`

It will download the files associated with the AWS provider and if it is successful, you’re good to go.

:-) 



# Understanding HashiCorp Terraform


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

Terraform evaluates ALL of the .tf files in a directory, so lines of code can be moved around. Instead of main.tf, you might have one s3.tf file for all of your AWS S3 buckets, policies, etc; and so on.

If your project comes very large you can abstract all the contents of a directory as a "module" and call on it from a root-directory. Then you can use your variables and outputs to insert and extract stateful information between modules.

Variables can be declared empty and be set when you run `terraform apply` (through a prompt), or they can be declared with a "default value". You can also specify certain conditions on them, like type. 

If you need to specifiy a LOT of variables, it can be convenient to use a variable definitions file, explicitly named terraform.tfvars or terraform.tfvars.json.

## Step 2.1: Deploying with Terraform

Navigate to the basic_project directory: 

`cd basic_project`

Initialize the Terraform project:

`terraform init`

Deploy the Terraform resources:

`terraform apply`

It will provide you with the deployment plan, inform you what resources will be created and such and then ask you to confirm. 


## Understanding State




# Understanding Elasticsearch
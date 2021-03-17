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


Move on to the underlying directories.



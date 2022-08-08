## Terraform Modules for Cloud Custodian to Enforce EaR Security Policies

Event Driven EaR Security Policies have been implemented using Cloud Custodian based Lambda Polices to enforce EaR on all Non-Prod and Prod AWS Accounts for the following AWS Services (SQS, Kinesis, S3, EFS, EC2, RDS, EMR, ES, and Redshift).

This collection of Terraform templates helps provision resources that can be referenced by Cloud Custodian policies:

- **Remediation Role:** A consistent IAM role that can be referenced across multiple accounts in remediation policies (encryption at rest, termination of non-compliant resources, etc). It is implemented in a remote/child account. 

- **Event Bus Forwarder:** A module which can be deployed in a member/child account to forward specific CloudTrail events to a central event bus in another account. It is implemented in a remote/child account. 

- **Event IAM Role:** A module which defines the IAM Role for forwarding events to the central management account and the IAM Policy for defining each target event bus. It is implemented in a remote/child account.  

Here is how these three modules work in practice for a remote/child account:

- We provision the `remediation_role` module into a remote/child account using Terragrunt/Terraform as described in the [Terraform repository](https://github.com/apprek/projects/tree/main/Terraform). This creates a `CloudCustodian-Remediations` role in a remote/child account.
- We provision the `Event IAM Role` module into a remote/child account using Terragrunt/Terraform as described in the previous link above. This creates a `CloudCustodian-EventForwarder` role in a remote/child account.
- We provision the `event_bus_forwarder` module which creates an EventBridge Rule named `custodian-eventbus-forwarder`. This rule is configured to begin forwarding selected CloudTrail events to the event bus in the central management/parent account. 
- Cloud Custodian policies like those in `./security/ear_enforcement` are _already_ running in central management/parent account.
  - Those policies run in response to specific CloudTrail events. By forwarding events from the remote/child account to the central management/parent account, those existing policies will automatically begin to fire for the remote/child account.
  - The policies are designed to run in the member account using a `CloudCustodian-Remediations` role. Since we've created that role, everything is in place for the central policies to do their job.

**EaR EventBased Automated Remediation Image**

<img src="https://github.com/apprek/projects/blob/4145aed9cc9adafaa2b2e4adaa6598be4cfdfb2a/Terraform/EaR_Diagram.pdf"  title="EaR EventBased Automated Remediation Image">




### EaR EventBased Automated Remediation Steps

1. User makes API call to create an AWS resource (ex: S3 Bucket) in a  via the console, cli, or SDK 
2. This creates a CloudTrail Event that is sent to the EventBrige default bus
3. The EventBrige rule named `custodian-eventbus-forwarder` in the remote/child account forwards the event to the EventBridge EventBus of the central management/parent account
4. The EventBrige rule in the central management/parent account forwards the event to the appropriate Cloud Custodian based Lambda Function
5. The Cloud Custodian based Lambda Function will assume the remdiation role named `CloudCustodian-Remediations` on the remote account and either enable encryption or terminate the resource depending if encryption can be enable using this process or not.


### Terraform setup for Event Driven EaR 

1.	Pull down “cloud-custodian-policies” from GITHub repo
  -	https://github.com/apprek/projects/tree/main/ear_enforcement 
2.	Log into remote AWS account that needs that needs the IAM Roles and Event rules setup 
3.	Confirm that there is a IAM Role named “infrastructure-terraform” set up. If not you will need to set up the role in the following manner.
  -	Trust relationship with the  {central management/parent account} 
  -	Inline AWS Managed Policy “AdministractorAccess”
4.	Set environment variables for AWS Platinum account on Unix terminal. This includes the
  -	AWS_ACCESS_KEY_ID
  -	AWS_SECRET_ACCESS_KEY
  - AWS_SESSION_TOKEN
*You can confirm its working with the following commands “aws sts get-caller-identity”

5.	Install Terrargrunt  
  -	Follow installation steps listed in the following link https://terragrunt.gruntwork.io/docs/getting-started/install/
6.	Cd  to the  ~/cloud-custodian-policies/terraform directory
7.	Do ls -al command  and notice 3 key directories which will be used to 
  -	event_bus_forwarder
  -	event_iam_role
  -	remediation_role
8.	You will repeat the following steps for each directory listed above in the previous step.
  -	Cd to <directory> ex: event_bus_forwarder
  -	Mkdir <name of AWS Account> if it does not already exist
  -	Cp ./remote_account_a/terragrunt.hcl  ./remote_account_b>
  -	Cd to <name of AWS Account> and edit the terragrunt.hcl file with nano, vim or your favorite text editor. Change the following items highlighted in bold which include the AWS Count Number, the Environment tag and the HostStage Tag.
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../" #modules/event_bus_forwarder"
}

inputs = {
  provisioning_role_arn = "arn:aws:iam::< AWS Account Number>:role/infrastructure-terraform"

  tags = {
    Product      = "infrastructure"
    Environment  = "<Environment Name>"
    Type         = "cloud-custodian"
    HostStage    = "<non-prod or prod>"
    Owner        = "cloud-infrastructure"
    OwnerContact = "cloud-infrastructure@corp_xyz.com"
    Company      = "corp_xyz"
  }
}

9.	Run the following commands 
  -	Terragrunt init
  -	Terragrunt plan -out=<name of AWS Account>.tfplan
  -	Terragrunt apply <name of AWS Account>.tfplan
10.	Repeat steps 6 thru 9 for the remaining 2 directories (event_iam_role and  remediation_role)



### Key Files and Modules for Terraform Setup

  - main.tf

  - provider.tf

  - variables.tf

  - terragrunt.hcl

  - event_bus_forwarder/
  - event_iam_role/
  - remediation_role/
  - modules/
  - ├── event_bus_forwarder
        ├── main.tf
        ├── variables.tf
        └── versions.tf
    ├── event_iam_role
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
    └── remediation_role
        ├── main.tf
        ├── outputs.tf
        ├── policies.tf
        ├── variables.tf
        └── versions.tf


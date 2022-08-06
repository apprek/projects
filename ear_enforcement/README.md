# Encryption at Rest enforcement policies for Cloud Custodian

## Overview

The policies collected here ensure that covered resources are encrypted at rest, by either:

* Enabling encryption at creation time where possible
* Deleting/terminating resources if enabling encryption on the fly isn't feasible

In either case, we make a best effort attempt to also notify the creator by mail.

## Deployment

### Prerequisites

* An EventBridge rule forwarding relevant events from a resource-owner account to the event bus in central management account.
* A `CloudCustodian-Remediations` role in the central management account with permission to assume a role of the same name in a resource-owner account.
* A `CloudCustodian-Remediations` role in each resource-owner account. This role needs:
  * A trust policy allowing it to be assumed from central management account
  * Sufficient resource-level access to perform remediations, including:
    * Listing resources
    * Configuring encryption
    * Terminatins non-compliant resources

### Deploying Policies

With prerequisites in place:

* [Install](https://cloudcustodian.io/docs/quickstart/index.html#install-cc) a current version of Cloud Custodian.
* Configure your AWS CLI to point to central management account.
* Run: `custodian run -s ./out -v cloud-custodian-policies/security/ear_enforcement/*.yml`



## Monitoring & Troubleshooting

### Metrics

Metrics for these policies are published to the resource owner accounts (such as AWS-Green), in the `CloudMaid` namespace of CloudWatch Metrics. As of July 2020, a CloudWatch dashboard is available [here](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=CloudCustodian-EncryptionAtRestEnforcement).

The dashboard includes widgets to show affected resource counts and runtime exceptions for encryption enforcement policies.

### Logging

#### CloudWatch

These policies execute as Lambda functions in the central management account, so CloudWatch logs of policy runs can be found in that account. Log group names will be in the format `/aws/lambda/custodian-<policy name>`. So logs for the `ec2-encryption_remediation` policy will be available as `/aws/lambda/custodian-ec2-encryption_remediation`.

#### S3

These policies are also configured to write logs to `s3://bucket/cloud-custodian` in the centralized logging account (AWS-Indigo). An example location might be:

```
s3://bucket/cloud-custodian/{central management account}/us-east-1/ec2-check_encrypted_volumes/2020/07/02/12
```

Which generalizes to:

```
s3://bucket/cloud-custodian/<runner account>/<region>/<policy name>/<year>/<month>/<day>/<hour>
```

That prefix will have a complete description of resources affected by the policy, along with a run log and policy metadata that can be helpful for troubleshooting.

**Note:** If a Lambda policy runs more than once in an hour, it will overwrite data for the previous run. In those cases, the detailed logs are retained as previous versions in S3.

### Notes and Exclusions

#### General

* For any policies which delete/terminate resources, exclude resources generated via CloudFormation. Encryption concerns stemming from templates should be addressed within the template.

#### Event Bus Forwarding

* When forwarding resource creation events to the central management account event bus, be sure to add a filter to be sure that `errorCode` is null ([reference](https://docs.aws.amazon.com/eventbridge/latest/userguide/eventbridge-event-patterns-null-and-empty-strings.html)). This avoids firing policies in response to failed creation attempts, including _most_ create attempts for resources that already exist.

#### EC2

* Do not terminate instances launched by Auto Scaling groups or EMR. Encryption options should be changed within the launch template or EMR cluster configuration.

#### SQS

* When service or cross-account integrations are required for a queue, there will be an SQS queue policy in place. In those cases, we *do not* automatically enable encryption. We *encourage* encryption using the customer-managed "sqs" key. That is not a transparent change though - queue consumers may need to be updated to ensure that they have `Decrypt` permissions for the "sqs" key.
* For policies that respond to `CreateQueue` events, it is not enough to test that the API response was successful. Duplicate queue creations do not throw errors. Our best option is to include an extra filter to be sure that the queue was created less than 1 day ago.

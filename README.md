# Strapi on EC2 — Terraform with One-Click Deploy and Stop Workflows

Terraform that provisions an EC2 instance running a containerised [Strapi](https://strapi.io/) application, wrapped in two manually triggered GitHub Actions workflows: **deploy** brings the environment up, **stop** tears it back down.

## Why this exists

Always-on cloud infrastructure for something you use intermittently — a demo, a client review environment, a staging instance — is money on fire. Fargate and RDS bill by the hour whether or not anyone visits.

This repository makes the environment disposable. Pressing *Run workflow* on `deploy.yml` builds the whole thing from scratch in a few minutes; pressing it on `stop.yml` destroys it. The state lives in S3, not on anyone's laptop, so it does not matter who triggers which.

Typical uses:

- A staging environment that only exists during working hours
- A demo environment spun up for a specific meeting and destroyed afterwards
- Teaching Terraform plus GitHub Actions without leaving billable resources running

## How it works

```
GitHub Actions (workflow_dispatch)
        |
        |  AWS + Docker Hub credentials from repository secrets
        v
Terraform (S3 remote state)
        |
        v
EC2 instance  <-- user-data from terraform/temp.tpl
        |          installs Docker, pulls the image, runs Strapi
        v
Strapi, reachable on the instance public address
```

The instance is built from the latest Ubuntu 22.04 (Jammy) AMI, looked up dynamically rather than hardcoded, so the configuration does not rot as AMI IDs change.

## Repository layout

| Path | Purpose |
| --- | --- |
| `terraform/main.tf` | AMI lookup, EC2 instance, supporting resources |
| `terraform/variables.tf` | Input variables, including Docker Hub credentials |
| `terraform/terraform.tfvars` | Default values |
| `terraform/temp.tpl` | User-data template — bootstraps Docker and starts the container |
| `terraform/backend.tf` | S3 remote state configuration |
| `.github/workflows/deploy.yml` | Manual deploy: init, validate, plan, apply |
| `.github/workflows/stop.yml` | Manual teardown: destroy |

## Setup

**1. Configure remote state**

Edit `terraform/backend.tf` with your own S3 bucket and key.

**2. Add repository secrets**

Under **Settings → Secrets and variables → Actions**:

| Secret | Purpose |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Credentials for the Terraform AWS provider |
| `AWS_SECRET_ACCESS_KEY` | Matching secret key |
| `DOCKER_HUB_USERNAME` | Passed as a Terraform variable for the image pull |
| `DOCKER_HUB_PASSWORD` | Matching password or access token |

**3. Deploy**

Actions → **Deployment** → *Run workflow*. It runs `terraform init`, `validate`, `plan`, and `apply`.

**4. Stop**

Actions → **stop.yml** → *Run workflow*. This destroys the environment.

## Running it by hand

```bash
cd terraform
terraform init
terraform apply -var="docker_hub_username=..." -var="docker_hub_password=..."
```

```bash
terraform destroy    # when you are done
```

## Notes and limits

- **Both workflows are `workflow_dispatch` only.** Nothing deploys on push — deliberate, so a merge cannot silently create infrastructure.
- **Docker Hub credentials are passed as Terraform variables** and therefore land in the state file. The state bucket must be private and encrypted. Prefer an ECR pull role over Docker Hub credentials if you are adapting this for anything sensitive.
- **Storage is ephemeral.** Everything Strapi writes lives on the instance and disappears with it. That is the point of a disposable environment; attach EBS or RDS if you need the data to outlive the stack.
- **No state locking.** Add a DynamoDB lock table before more than one person can trigger the workflows, or a concurrent deploy and stop will corrupt state.
- Use `terraform destroy` or the stop workflow rather than terminating the instance in the console — otherwise state drifts from reality.

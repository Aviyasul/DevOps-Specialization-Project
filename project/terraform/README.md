# Terraform - EC2 Provisioning (project/terraform)

This directory contains Terraform configuration to provision a simple EC2-based "builder" instance in AWS along with supporting networking resources and helper files. It includes a small reusable `ec2` module and a root configuration which demonstrates provisioning an instance using public subnets and an AMI data source.

---

## Repository / Folder snapshot
Files in this folder:

- `provider.tf` — Terraform settings and provider requirements
- `data.tf` — AMI lookup data source (Ubuntu Jammy 22.04, most recent)
- `main.tf` — Root resources including Security Group, TLS key pair, local file for the private key, AWS key pair, and EC2 instance resource
- `variables.tf` — Root module variables such as `instance_type`, `subnet_id`, `vpc_id` and `my_ip` (defaults are set in this file)
- `outputs.tf` — Useful outputs: SSH private key path, SSH key name, instance public IP, security group id
- `modules/ec2/` — A reusable module that provisions an EC2 instance with its own AMI data sources, key pair, and security group
- `.terraform/`, `terraform.tfstate`, `terraform.tfstate.backup` — State files and provider plugin cache (local)
- `builder_key.pem` — Example generated SSH private key that the configuration saves to the module path (if you run apply locally)

---

## What this configuration does
- Looks up a current Ubuntu AMI using a `data.aws_ami` data source
- Creates an SSH key pair (generated locally and uploaded to AWS)
- Saves the private key locally (`builder_key.pem`) and adds a `local_file` for safekeeping
- Creates a security group that allows SSH (port 22) and port 5001 (used by app demos)
- Launches a single EC2 instance with the chosen AMI, instance type, subnet and security group
- Exposes outputs for retrieving the private key location, SSH key name, instance public IP and security group id

---

## Important files and where to look
- `main.tf` — Primary root configuration for the EC2 instance and security group
- `data.tf` — AMI lookup for Ubuntu
- `modules/ec2/main.tf` — Module implementation that can be reused or called from other configurations
- `modules/ec2/variables.tf` — Module-level variables and defaults
- `outputs.tf` — `ssh_private_key_path`, `ssh_key_name`, `public_ip`, `security_group_id`

---

## How to use (local development)
> NOTE: The configuration assumes you're working against your AWS account and have credentials configured (environment variables, AWS profile, or an appropriate IAM role). Always review and secure credentials appropriately.

1. Open a terminal in this directory (project/terraform).
2. Initialize Terraform providers and modules:

```bash
terraform init
```

3. (Optional) Validate the configuration:

```bash
terraform validate
```

4. Preview changes:

```bash
terraform plan -out plan.tfplan
```

5. Apply the plan to create resources:

```bash
terraform apply "plan.tfplan"
# or directly: terraform apply
```

6. After a successful apply, view outputs:

```bash
terraform output
# or for a specific output
terraform output public_ip
```

7. If you used the default `local_file` resource, the private key will be saved at `./builder_key.pem` (or `${path.module}/builder_key.pem` if running from module) — set permission and use the key to SSH to the instance.

---

## Git actions (what you ran in the last terminal)
You previously ran Git commands from this directory to push your changes to a remote repository. Typical commands you used (or should use) are:

```bash
# Initialize repo (if needed)
git init

# Add files and commit
git add .
git commit -m "Add Terraform EC2 provisioning code"

# Add remote and push
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

The last command seen in your terminal was `git push -u origin main` from `C:/Users/Aviya/python 3/project/terraform` and it returned exit code 0 — meaning your push succeeded and the current branch was pushed to the `main` branch on the remote.

---

## Security & cleanup notes
- The generated private key (`builder_key.pem`) is sensitive. Keep it secure and never commit it to a public repo. Add `builder_key.pem` to `.gitignore` if you plan to keep the file locally.
- The configuration permits open ingress (0.0.0.0/0) for convenience in some resources — update `cidr_blocks` to restrict access to your known IP ranges where appropriate.
- Use `terraform destroy` when you no longer need the resources to avoid unexpected AWS charges.

```bash
terraform destroy
```

---

## Next steps / recommendations
- Move sensitive values (if any) into variables and use `terraform.tfvars` or environment variables rather than hardcoding.
- Add better variable validation and documentation for required inputs such as `vpc_id` and `subnet_id`.
- Consider storing Terraform state in an S3 backend with state locking (DynamoDB) for team usage instead of local state files.

---

## Questions / troubleshooting
If you run into issues:
- Double-check your AWS credentials and default region.
- If the SSH connection fails, verify the `builder_key.pem` permissions and the instance's public IP.
- Use `terraform plan` to preview changes and `terraform validate` for basic checks.

---

If you'd like, I can:
- Add a `.gitignore` entry for `builder_key.pem` and for `.terraform/` or other local files,
- Create an example `terraform.tfvars` file and/or move to an S3 remote backend,
- Provide a short script to help set region/credentials and run terraform commands.


# licensing-infrastructure
Infrastructure for GOV.UK Licensing applications

This repo uses terraform to manage AWS infrastructure. It is separated into two modules:

* `bootstrap/`, which creates the base infrastructure needed for everything else to run. This includes terraform state storage, pipelines and engineer permissions
* `terraform/`, which contains all the infrastructure to run an instance of the GOV.UK Licensing service.

# Set up

## Mise

This repository uses [mise](https://mise.jdx.dev/) to manage tool versions and environment variables.

After installing mise, you should set up your shell to automatically activate mise following [these instructions](https://mise.jdx.dev/installing-mise.html#shell-specific-installation-activation), then run `mise install` and `mise trust`.

## Development tools

Run `make prepare` to install the pre-commit hooks configured for this repository

# Deploying

## Bootstrap

You should only need to deploy the bootstrap to initialise the AWS account, or rarely if the bootstrap resources are changed or accidentally deleted.

* Ensure you have set up TOTP MFA on your base user account as described in the gds-cli README.
* Fill in `TOTP_MFA_SERIAL` and the `*_ACCOUNT_ID` values in `bootstrap-aws-config.template` and copy it to `~/.aws/config`. This will give you profiles to assume the bootstrap roles set up in the AWS accounts.
* Fill in the values of `bootstrap-secrets.tfvars.template` in the root directory and move it to the `bootstrap` directory. You can name this file `secrets.auto.tfvars` to have the values automatically applied. A pre-filled copy can be found in the teams shared storage account under "Engineering/Infrastructure".
* If the account has already been bootstrapped and contains some/all of the bootstrap resources, check the "Engineering/Infrastructure" cloud storage folder for the most recent tfstate file. If it's there, copy it to `terraform.tfstate` in the `bootstrap/` directory. If it's not and bootstrap resources exist, you will need to import these manually using `terraform import <...>` for each resource.
* Ensure you are connected to the VPN. The bootstrap role is IP restricted and will not work otherwise.
* Run `aws-vault exec {ACCOUNT}-bootstrap -- terraform plan -var-file {ACCOUNT}.tfvars -out {ACCOUNT}.tfplan` to generate a plan, substituting the account name (development, staging or production) for "{ACCOUNT}". Review this plan to ensure the changes are sensible (you can run `terraform show {ACCOUNT}.tfplan` to view the changes again)
* Run `aws-vault exec {ACCOUNT}-bootstrap -- terraform apply -var-file {ACCOUNT}.tfvars {ACCOUNT}.tfplan` when you're happy with the plan.
* Copy the latest tfstate (`bootstrap/terraform.tfstate`) to the shared storage account infrastructure folder.

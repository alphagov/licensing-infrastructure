# licensing-infrastructure
Infrastructure for Licensing applications

# Set up

## Mise

This repository uses [mise](https://mise.jdx.dev/) to manage tool versions and environment variables.

After installing mise, you should set up your shell to automatically activate mise following [these instructions](https://mise.jdx.dev/installing-mise.html#shell-specific-installation-activation), then run `mise install` and `mise trust`.

## Secrets

To apply the bootstrap terraform, you will need to fill in the values of `bootstrap-secrets.tfvars.template` in the root directory and move it to the `bootstrap` directory. You can name this file `secrets.auto.tfvars` to have the values automatically applied.

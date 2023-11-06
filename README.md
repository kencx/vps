# VPS

This project contains the infrastructure-as-code for deploying and configuring a Hetzner VPS.

Applications:
- Caddy as a file server and reverse proxy
- [sxkcd](https://github.com/kencx/sxkcd)
- cgit
- webhook server

## Build Alpine Snapshot on Hetzner

The configuration in `./alpine` builds an Alpine Linux base image in Hetzner
Cloud with Packer and Ansible.

```bash
$ cd alpine

$ cat <<EOF > auto.pkrvars.hcl
hcloud_token = changeme
ssh_public_key_path = ~/.ssh/id_ed25519.pub
EOF

$ packer build -var-file="auto.pkrvars.hcl" .
```

## Provision VM

Populate the necessary variables and run `terraform apply`:

```bash
$ cd terraform

$ cat <<EOF > terrafom.tfvars
hcloud_token = changeme
cloudflare_api_token = changeme

vps_ssh_public_key_path = ~/.ssh/id_ed25519.pub
vps_ssh_private_key_path = ~/.ssh/id_ed25519

vps_username = "user"
vps_password = "password"
vps_letsencrypt_email = "user@example.com"
EOF

$ terraform plan
$ terraform apply
```

This configuration creates two local files that will be used by Ansible:
- `tf_ansible_vars.yml` - Ansible vars file with the above variables and Cloudflare
  domains
- `tf_ansible_inventory` - Ansible inventory file with the VM's IP address

The state is saved to an S3 bucket on a local Minio instance by default.

## Configure VM

Ansible bootstraps the new VM before installing and configuring our applications
to run. It uses the two Terraform-generated files from the previous step.
```bash
$ cd ansible

$ ansible-playbook main.yml
```

Check the following files before running the playbook:
- `main.yml` - Replace any variables if necessary
- `tasks/templates/docker-compose.yml.j2` - the Docker containers to start
- `tasks/templates/Caddyfile.j2` - the routes to serve

## Docker Builds

Custom Docker images are built in `apps/`:

- `ghcr.io/kencx/caddy` - Custom caddy image with plugins
- `ghcr.io/kencx/cgit` - Custom cgit image (with and without Nginx)
    - Custom should be added into `/etc/cgit.d/custom`.

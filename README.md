# VPS

This project contains the configuration for a Hetzner VPS.

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

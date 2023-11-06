.PHONY: venv pre-commit

venv:
	@python3 -m venv .venv

pip.install: requirements.txt venv
	source .venv/bin/activate && pip install -r $< --disable-pip-version-check -q

pre-commit.install: pip.install
	source .venv/bin/activate && pre-commit install

pre-commit:
	pre-commit run --all-files

galaxy.install: requirements.yml
	ansible-galaxy install -f -r $<

packer.build: alpine/auto.pkrvars.hcl
	cd alpine && packer build -var-file="auto.pkrvars.hcl" .

deploy: terraform/terraform.tfvars
	cd terraform && terraform apply -auto-approve

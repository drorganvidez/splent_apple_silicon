VM_NAME := splent-dev
LIMA_CFG := infra/lima/splent-dev.yaml
PLAYBOOK := infra/ansible/provision.yml

ARCH := $(shell uname -m)

.PHONY: up provision ssh down destroy status check-arch

check-arch:
	@if [ "$(ARCH)" != "arm64" ]; then \
		echo "ERROR: This environment supports Apple Silicon (arm64) only."; \
		echo "Detected architecture: $(ARCH)"; \
		exit 1; \
	fi

up: check-arch
	cd $(CURDIR) && limactl start --name=$(VM_NAME) $(LIMA_CFG)
	@command -v limactl >/dev/null 2>&1 || (echo "Please install Lima: brew install lima" && exit 1)
	@command -v ansible-playbook >/dev/null 2>&1 || (echo "Please install Ansible: brew install ansible" && exit 1)
	limactl start --name=$(VM_NAME) $(LIMA_CFG)
	$(MAKE) provision

provision:
	@PORT=$$(limactl show-ssh $(VM_NAME) | sed -n 's/.*-p \([0-9]*\).*/\1/p'); \
	USER=$$(limactl show-ssh $(VM_NAME) | sed -n 's/.*-l \([^ ]*\).*/\1/p'); \
	echo "[splent]" > /tmp/inventory.ini; \
	echo "splent ansible_host=127.0.0.1 ansible_port=$$PORT ansible_user=$$USER" >> /tmp/inventory.ini; \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /tmp/inventory.ini $(PLAYBOOK)

ssh:
	limactl shell $(VM_NAME)

down:
	limactl stop $(VM_NAME)

destroy:
	limactl delete $(VM_NAME)

status:
	limactl list
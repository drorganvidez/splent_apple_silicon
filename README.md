# SPLENT Dev VM (Apple Silicon Only)

This development environment is designed **exclusively for Apple Silicon (M1/M2/M3/M4/M5)** Macs.

It uses **Lima + Ubuntu + Ansible** to provide a reproducible Linux VM with Docker.

---

## Requirements

Install dependencies:

```bash
brew install lima ansible
```

## Start the Environment

```bash
make up
```

This will:

- Create/start an Ubuntu ARM64 VM
- Install Docker
- Mount the project into /workspace
- Configure Git
- Provision the system automatically

## Access the VM

```bash
make ssh
```

The project is available at `/workspace`

## Stop the VM

```bash
make down
```

## Destroy the VM completely

```bash
make destroy
```
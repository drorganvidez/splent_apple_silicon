# SPLENT Dev VM (Apple Silicon Only)

This development environment is designed **exclusively for Apple Silicon (M1/M2/M3/M4/M5)** Macs.

It uses **Lima + Ubuntu + Ansible** to provide a reproducible Linux VM with Docker.

---

## Requirements

Install dependencies:

```bash
brew install lima ansible
brew install socket_vmnet
```

Activate service

```bash
sudo brew services start socket_vmnet
```

Config socket

```bash
sudo mkdir -p /etc/socket_vmnet
sudo nano /etc/socket_vmnet/config.json
```

```json
{
  "networks": [
    {
      "name": "splentnet",
      "mode": "host",
      "subnet": "10.10.10.0/24",
      "gateway": "10.10.10.1",
      "dhcp": {
        "start": "10.10.10.100",
        "end": "10.10.10.200"
      }
    }
  ]
}
```

Restart service

```bash
sudo brew services restart socket_vmnet
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
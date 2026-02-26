# SPLENT Dev VM (Apple Silicon)

This project provides a simple Ubuntu development VM for **Apple Silicon (M1/M2/M3)** using:

- VMware Desktop (free for personal use)
- Vagrant
- Ubuntu ARM64

It replicates the classic Vagrant workflow used on Intel Macs.

---

## Requirements

You need:

- Apple Silicon Mac (arm64)
- VMware Desktop (free personal license)
- Vagrant
- Vagrant VMware plugin

---

## Install VMware Desktop

Download VMware Desktop (Fusion) from the official VMware website (link: https://support.broadcom.com/group/ecx/downloads)

It is free for personal/home use (registration required).

---

## Install Vagrant

```bash
brew install vagrant
```

Install the VMware plugin for Vagrant
```bash
vagrant plugin install vagrant-vmware-desktop
```

## Start the VM

From the project root:

```bash
vagrant up --provider=vmware_desktop
```

## SSH into the VM

```bash
vagrant ssh
```

## Stop the VM

```bash
vagrant halt
```

## Destroy the VM
```bash
vagrant destroy
```

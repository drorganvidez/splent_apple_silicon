Vagrant.configure("2") do |config|

  # --- VM BASE -----------------------------------------------------------

  config.vm.hostname = "splent-dev"

  # --- HOST DETECTION ----------------------------------------------------

  is_windows = Vagrant::Util::Platform.windows?
  is_macos   = Vagrant::Util::Platform.darwin?

  host_arch = if is_windows
    # Windows: typical values are "amd64" or "arm64"
    ENV["PROCESSOR_ARCHITECTURE"].to_s.downcase
  else
    `uname -m`.strip
  end

  is_arm64 = (host_arch == "arm64") || (host_arch == "aarch64") || host_arch.include?("arm")

  # --- BOX / PROVIDER ----------------------------------------------------

  if is_arm64
    # ARM host: use an ARM64 box
    config.vm.box = "gyptazy/ubuntu22.04-arm64"

    # On macOS ARM, VMware Desktop is the common path (VirtualBox is usually not viable)
    if is_macos
      config.vm.provider "vmware_desktop" do |v|
        v.vmx["displayName"] = "splent-dev"
        v.vmx["memsize"]     = "4096"
        v.vmx["numvcpus"]    = "2"
      end
    end
  else
    # AMD64 host: standard Ubuntu box
    config.vm.box = "ubuntu/jammy64"

    config.vm.provider "virtualbox" do |vb|
      vb.name = "splent-dev"
      vb.customize ["modifyvm", :id, "--memory", "4096"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end

  # --- NETWORK -----------------------------------------------------------

  config.vm.network "private_network", ip: "10.10.10.10"

  # --- SYNCED FOLDER -----------------------------------------------------

  if is_arm64 && is_macos
    # VMware shared folders vary; rsync is portable and avoids surprises
    config.vm.synced_folder ".", "/workspace",
      type: "rsync",
      rsync__auto: true
  else
    # VirtualBox path
    if is_windows
      # Windows: SMB avoids vboxsf/Guest Additions mismatches and supports mfsymlink
      config.vm.synced_folder ".", "/workspace",
        type: "smb"
    else
      # macOS/Linux: VirtualBox shared folder
      config.vm.synced_folder ".", "/workspace",
        type: "virtualbox",
        mount_options: ["dmode=775,fmode=664"]
    end
  end

  # --- COPY SSH KEYS -----------------------------------------------------

  if File.exist?(File.expand_path("~/.ssh/id_rsa"))
    config.vm.provision "file",
      source: "~/.ssh/id_rsa",
      destination: "/home/vagrant/.ssh/id_rsa"

    config.vm.provision "file",
      source: "~/.ssh/id_rsa.pub",
      destination: "/home/vagrant/.ssh/id_rsa.pub"
  end

  # --- COPY GITCONFIG ----------------------------------------------------

  if File.exist?(File.expand_path("~/.gitconfig"))
    config.vm.provision "file",
      source: "~/.gitconfig",
      destination: "/home/vagrant/.gitconfig"
  end

  # --- DOCKER INSTALLATION ----------------------------------------------

  config.vm.provision "shell", inline: <<-'SHELL'
    set -e
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get install -y \
      ca-certificates curl gnupg lsb-release build-essential

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      > /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    usermod -aG docker vagrant || true

    # Ensure SSH dir exists
    mkdir -p /home/vagrant/.ssh
    chown vagrant:vagrant /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh

    # Fix SSH keys inside VM (if provisioned)
    if [ -f /home/vagrant/.ssh/id_rsa ]; then
      chmod 600 /home/vagrant/.ssh/id_rsa
      chown vagrant:vagrant /home/vagrant/.ssh/id_rsa
    fi
    if [ -f /home/vagrant/.ssh/id_rsa.pub ]; then
      chmod 644 /home/vagrant/.ssh/id_rsa.pub
      chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub
    fi

    # GitHub SSH config
    cat <<'EOF' > /home/vagrant/.ssh/config
Host github.com
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
EOF

    chmod 600 /home/vagrant/.ssh/config
    chown vagrant:vagrant /home/vagrant/.ssh/config

    # Auto cd to /workspace
    cat <<'EOF' > /home/vagrant/.bashrc_workspace
if [ -d /workspace ]; then
  cd /workspace
fi
EOF

    if ! grep -q 'source ~/.bashrc_workspace' /home/vagrant/.bashrc 2>/dev/null; then
      echo 'source ~/.bashrc_workspace' >> /home/vagrant/.bashrc
    fi

    chown vagrant:vagrant /home/vagrant/.bashrc_workspace /home/vagrant/.bashrc

    echo "✔ SPLENT VM ready (Docker + SSH + workspace)."
  SHELL

end

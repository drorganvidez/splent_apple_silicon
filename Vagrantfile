Vagrant.configure("2") do |config|
  config.vm.hostname = "splent-dev"

  host_arch = `uname -m`.strip

  if host_arch == "arm64"
    config.vm.box = "gyptazy/ubuntu22.04-arm64"
    config.vm.provider "vmware_desktop" do |v|
      v.vmx["displayName"] = "splent-dev"
      v.vmx["memsize"] = "4096"
      v.vmx["numvcpus"] = "2"
    end

    config.vm.network "private_network", ip: "10.10.10.10"

    config.vm.synced_folder ".", "/workspace", type: "nfs"

  else
    config.vm.box = "ubuntu/jammy64"

    config.vm.network "private_network", ip: "10.10.10.10"

    config.vm.synced_folder ".", "/workspace",
      type: "virtualbox",
      mount_options: ["dmode=775,fmode=664"]

    config.vm.provider "virtualbox" do |vb|
      vb.name = "splent-dev"
      vb.customize ["modifyvm", :id, "--memory", "4096"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
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

    if [ -f /home/vagrant/.ssh/id_rsa ]; then
      chmod 600 /home/vagrant/.ssh/id_rsa
      chmod 644 /home/vagrant/.ssh/id_rsa.pub
      chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
    fi

    mkdir -p /home/vagrant/.ssh

    cat <<'EOF' > /home/vagrant/.ssh/config
Host github.com
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
EOF

    chmod 600 /home/vagrant/.ssh/config
    chown vagrant:vagrant /home/vagrant/.ssh/config

    cat <<'EOF' > /home/vagrant/.bashrc_workspace
if [ -d /workspace ]; then
  cd /workspace
fi
EOF

    echo 'source ~/.bashrc_workspace' >> /home/vagrant/.bashrc
    chown vagrant:vagrant /home/vagrant/.bashrc_workspace
  SHELL
end
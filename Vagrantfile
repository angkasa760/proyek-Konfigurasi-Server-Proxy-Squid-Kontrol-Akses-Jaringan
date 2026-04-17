# -*- mode: ruby -*-
# vi: set ft=ruby :
# ===================================================================
# Vagrantfile — Lab Squid Proxy: CentOS 7 (Satu Perintah Setup)
# Prasyarat: Vagrant + VirtualBox terinstall di host
#
# Cara penggunaan:
#   vagrant up          — Buat dan start VM
#   vagrant ssh         — Login ke VM
#   vagrant halt        — Stop VM
#   vagrant destroy     — Hapus VM
# ===================================================================

Vagrant.configure("2") do |config|

  # ---------------------------------------------------------------
  # VM: Squid Proxy Server
  # ---------------------------------------------------------------
  config.vm.define "squid-server" do |server|
    server.vm.box = "centos/7"
    server.vm.hostname = "squid-proxy-server"

    # Network: NAT untuk internet + Host-only untuk lab
    server.vm.network "private_network", ip: "172.24.0.1"
    server.vm.network "forwarded_port", guest: 3128, host: 3128
    server.vm.network "forwarded_port", guest: 3129, host: 3129
    server.vm.network "forwarded_port", guest: 80,   host: 8080  # SARG reports

    # Resource VM
    server.vm.provider "virtualbox" do |vb|
      vb.name   = "Squid-Proxy-Lab-Server"
      vb.memory = "2048"
      vb.cpus   = 2
    end

    # Sync folder: proyek repo ke VM
    server.vm.synced_folder ".", "/vagrant/squid-lab"

    # Provisioning: install dan setup Squid otomatis
    server.vm.provision "shell", inline: <<-SHELL
      echo "======================================================"
      echo "  Squid Proxy Lab — Auto Provisioning"
      echo "======================================================"

      # Update system
      yum update -y -q

      # Install Squid & tools
      yum install -y squid openssl httpd curl net-tools

      # Copy konfigurasi dari proyek
      cp /vagrant/squid-lab/configs/squid/squid.conf /etc/squid/squid.conf
      cp /vagrant/squid-lab/configs/squid/blocked_sites.txt /etc/squid/blocked_sites.txt

      # Inisialisasi cache directory
      squid -z

      # Enable dan start service
      systemctl enable squid httpd
      systemctl start squid httpd

      # Buka firewall
      systemctl start firewalld
      firewall-cmd --permanent --add-port=3128/tcp
      firewall-cmd --permanent --add-port=80/tcp
      firewall-cmd --reload

      echo "======================================================"
      echo "  Setup selesai!"
      echo "  Proxy: http://172.24.0.1:3128"
      echo "  Laporan SARG: http://172.24.0.1/sarg (setelah generate)"
      echo "======================================================"
    SHELL
  end

  # ---------------------------------------------------------------
  # VM: Client Linux (opsional, uncomment untuk aktifkan)
  # ---------------------------------------------------------------
  # config.vm.define "client-linux" do |client|
  #   client.vm.box = "centos/7"
  #   client.vm.hostname = "client-linux"
  #   client.vm.network "private_network", ip: "172.24.0.10"
  #   client.vm.provider "virtualbox" do |vb|
  #     vb.name   = "Squid-Lab-Client-Linux"
  #     vb.memory = "512"
  #     vb.cpus   = 1
  #   end
  #   client.vm.provision "shell", inline: <<-SHELL
  #     echo "export http_proxy=http://172.24.0.1:3128" >> /etc/environment
  #     echo "export https_proxy=http://172.24.0.1:3128" >> /etc/environment
  #     echo "Proxy setting selesai. Test: curl -x http://172.24.0.1:3128 http://example.com"
  #   SHELL
  # end

end

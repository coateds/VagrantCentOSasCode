
Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.5"
  config.vm.network "private_network", type: "dhcp"
  config.vm.hostname = "CentOSasCode"
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "CentOSasCode"
    vb.gui = true  # brings up the vm in gui window
    vb.customize ["modifyvm", :id, "--vram", "128"]  # vid RAM
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]    
    vb.memory = 4096
    vb.cpus = 2  

    # Add an extra disk and a DVD drive mounted with the Guest Additions
    file_to_disk = "ExtraDisk.vmdk"
    unless File.exist?(file_to_disk)
      vb.customize [ "createmedium", "disk", "--filename", file_to_disk, "--format", "vmdk", "--size",  256]
    end
    vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", file_to_disk ]
    vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 2, "--device", 0, "--type", "dvddrive", "--medium", "C:\\Program Files\\Oracle\\VirtualBox\\VBoxGuestAdditions.iso"]
  end

  # Install gdisk with yum and upgrade with yum. 
  # This is not technically idempotent, but is effectively idempotent
  # create gdisk partitions with sgdisk, if already exist it throws an error 
  # and moves on... send the error to /dev/null
  config.vm.provision "shell", inline: <<-SHELL
    yum install gdisk -y
    # yum upgrade -y
    sgdisk -n 1:2048:22527 -t 1:8300 /dev/sdb 2> /dev/null
    sgdisk -n 2:$(sgdisk -F /dev/sdb):43007 -t 2:8300 /dev/sdb 2> /dev/null
    sgdisk -n 3:$(sgdisk -F /dev/sdb):63487 -t 3:8300 /dev/sdb 2> /dev/null
    echo "inline script complete"
  SHELL

  # This script will create file systems on new partitions if they do not exist
  config.vm.provision "shell", path: "provision_fs.sh"

  config.vm.provision "chef_solo" do |chef|
    chef.add_recipe "mountfs"
    chef.add_recipe "tz"
  end
end

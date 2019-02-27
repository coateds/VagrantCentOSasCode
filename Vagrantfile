
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

    file_to_disk = "ExtraDisk.vmdk"
    unless File.exist?(file_to_disk)
      vb.customize [ "createmedium", "disk", "--filename", file_to_disk, "--format", "vmdk", "--size",  256]
    end
    vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", file_to_disk ]
    vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 2, "--device", 0, "--type", "dvddrive", "--medium", "C:\\Program Files\\Oracle\\VirtualBox\\VBoxGuestAdditions.iso"]
  end
end

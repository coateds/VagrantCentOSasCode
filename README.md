# VagrantCentOSasCode
Build out a Gui CentOS Vagrant/VirtualBox with Bash and Chef provisioning

This instructional example demonstrates the ability to create and provision a CentOS 7.5 Vagrant box using infrastructure as code techniques. The build process will utilize both Bash scripting and Chef recipes/resources to configure the box with example disk partitions, the Gnome gui desktop, the VirtualBox Guest Additions and application software.

The first step is to configure extra storage devices:
```
# Add an extra disk and a DVD drive mounted with the Guest Additions iso
file_to_disk = "ExtraDisk.vmdk"
unless File.exist?(file_to_disk)
  vb.customize [ "createmedium", "disk", "--filename", file_to_disk, "--format", "vmdk", "--size",  256]
end
vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", file_to_disk ]
vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 2, "--device", 0, "--type", "dvddrive", "--medium", "C:\\Program Files\\Oracle\\VirtualBox\\VBoxGuestAdditions.iso"]
```

When complete, the lsblk command will show a second disk (sbd) and cdrom(sr0):
```
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   64G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   63G  0 part
  ├─centos-root 253:0    0   41G  0 lvm  /
  ├─centos-swap 253:1    0    2G  0 lvm  [SWAP]
  └─centos-home 253:2    0   20G  0 lvm  /home
sdb               8:16   0  256M  0 disk
sr0              11:0    1   82M  0 rom
```

Next is a block of inline shell script to partition the new disk with gdisk. This requires an install of gdisk using yum. The yum upgrade is a requirement for later steps. It might get moved in a future refactor. Finally, the sgdisk command (included in the gdisk package) is used to create the actual partitions. 

```
# Install gdisk with yum and upgrade with yum. 
# This is not technically idempotent, but is effectively idempotent
# create gdisk partitions with sgdisk, if already exist it throws an error 
# and moves on... send the error to /dev/null
config.vm.provision "shell", inline: <<-SHELL
  yum install gdisk -y
  yum upgrade -y
  sgdisk -n 1:2048:22527 -t 1:8300 /dev/sdb 2> /dev/null
  sgdisk -n 2:$(sgdisk -F /dev/sdb):43007 -t 2:8300 /dev/sdb 2> /dev/null
  sgdisk -n 3:$(sgdisk -F /dev/sdb):63487 -t 3:8300 /dev/sdb 2> /dev/null
  echo "inline script complete"
SHELL
```

The new lsblk output is:
```
sdb               8:16   0  256M  0 disk
├─sdb1            8:17   0   10M  0 part
├─sdb2            8:18   0   10M  0 part
└─sdb3            8:19   0   10M  0 part
```

In addition to inline scripts, it is possible to run a script file. Here, the provision_fs.sh file is placed in the host folder for the Vagrant guest (next to the Vagrantfile). If an attempt is made to create a file system over an existing file system an error will occur that will stop the provisioning of the rest of the box. because it is useful be able to provision the box repeatedly and only have the new or changed items have any effect, it is necessary to build a conditional to "guard" against attempts to create a new file system over an existing file system.

provision_fs.sh
```
# Provision file systems if they do not exist

echo "provision file systems"
if [ "$(lsblk -f | grep part1)" == "" ]
then
  echo "make fs part1"
  mkfs.ext2 -L part1 /dev/sdb1
fi

if [ "$(lsblk -f | grep part2)" == "" ]
then
  echo "make fs part2"
  mkfs.ext3 -L part2 /dev/sdb2
fi

if [ "$(lsblk -f | grep part3)" == "" ]
then
  echo "make fs part3"
  mkfs.ext4 -L part3 /dev/sdb3
fi
```

The conditional technique used here is to search (grep) the output of a "report" for the existence of a word or phrase that exists if the command has already been run. In this case if "part1" in included in the output of lsblk -f, then do not create the file system with the label "part1". So far Bash shell provisioning techniques have been used here. Chef is generally easier. Idempotence is often handled by default for a given Chef resource. If not, guards can be built and the conditional technique described here adapts well to these guards.

To provision with Chef, use the chef_solo provisioner:
```
config.vm.provision "chef_solo" do |chef|
  chef.add_recipe "mountfs"
end
```

Create a "cookbooks" folder in the host folder for the Vagrant guest. Then create mountfs\recipes\default.rb under that folder.

mountfs recipe
```
directory "part1"
directory "part2"
directory "part3"

# Add partition 1 to fstab if it is not already there
execute "add partition1 to fstab" do
  command "echo 'LABEL=part1\t\t/part1\t\t\text2\tdefaults\t0 0' >> /etc/fstab"
  not_if 'cat /etc/fstab | /usr/bin/grep part1'
end

# Add partition 2 to fstab if it is not already there
execute "add partition2 to fstab" do
  command "echo 'LABEL=part2\t\t/part2\t\t\text3\tdefaults\t0 0' >> /etc/fstab"
  not_if 'cat /etc/fstab | /usr/bin/grep part2'
end

# Add partition 3 to fstab if it is not already there
execute "add partition3 to fstab" do
  command "echo 'LABEL=part3\t\t/part3\t\t\text4\tdefaults\t0 0' >> /etc/fstab"
  not_if 'cat /etc/fstab | /usr/bin/grep part3'
end

# Mount all file systems in fstab
execute "mount -a"
```

The first three lines of this recipe are Chef resources that will create a directory if it does not already exist. The execute blocks will run a Bash command to append a line to the fstab file if it does not already exist. The not_if is a guard/conditional to test for a word/phrase in a line in the file. Only if it does not exist will the line be appended.

# Environment notes
* Windows 10
* Chocolatey
* VirtualBox (installed with choco)
* Vagrant (installed with choco)
* Git (installed with choco)

## Git process notes
* Master branch to be used to build extra disk partitions and file systems, then documentation
* Gui branch to build out Gnome and guest additions

### Step One and example
* Add the tz recipe to the Vagrantfile on the gui branch
* Now `vagrant up` will set the timezone when on the gui branch, but not on master.
* Proposed rules
  * Modify the README on the master branch
  * Modify the Vagrantfile on the gui branch
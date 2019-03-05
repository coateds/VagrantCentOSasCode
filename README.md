# VagrantCentOSasCode
Build out a Gui CentOS Vagrant/VirtualBox with Bash and Chef provisioning

This instructional example demonstrates the ability to create and provision a CentOS 7.5 Vagrant box using infrastructure as code techniques. The build process will utilize both Bash scripting and Chef recipes/resources to configure the box with example disk partitions, the Gnome gui desktop, the VirtualBox Guest Additions and application software.

The master branch of this repository builds out a CentOS box with 
1. An extra disk
2. The disk has 3 partitions created on it, each with different file systems and mounted via fstab
3. yum updates
4. The Gnome gui desktop
5. Version 6.0.4 Guest Additions and dependencies
6. The latest version of Git 2.x (WANdisco repository)
7. The latest version of VSCode (MS repository)
8. httpd web server with custom default web page

The install process is now entirely hands free. The Guest Additions upgrade is now handled with the vbguest plugin

With the merge of the refactor branch (refactor 1-3), more of the disk/partition/filesystem provisioning has been moved to Chef cookbooks/recipes. At this time, I do not see a high quality cookbook for creating gdisk partitions. Because the sgdisk commands are effectively idempotent, it seems reasonable to convert the commands to Chef execute resource blocks. So the next refactor will likely be a collapsing down of all disk partition/filesystem/mount processes to a single cookbook.

(Deprecated!) The install process is nearly hands free. However, the Guest Additions seems to require a gui logon before it will install. So the install process is:
1. `vagrant destroy -f` (if necessary, note the ExtraDisk.vmdk is deleted)
2. `vagrant up` (wait a long time)
3. logon to the gui
4. open a terminal and a logon script will run once to install the Guest Additions. Wait for this to finish
5. `vagrant reload` This will likely fail as described below in the section "Working with VirtualBox/Vagrant/Windows host"
6. `vagrant reload` again... 
7. logon to the gui again. Give the system a few seconds to stabilize before using.

## Walk through the automatic install process

### The first step is to configure extra storage devices:
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

<Deprecated>
In addition to inline scripts, it is possible to run a bash script file. Here, the provision_fs.sh file is placed in the host folder for the Vagrant guest (next to the Vagrantfile). If an attempt is made to create a file system over an existing file system an error will occur that will stop the provisioning of the rest of the box. Because it is useful be able to provision the box repeatedly and only have the new or changed items have any effect, it is necessary to build a conditional to "guard" against attempts to create a new file system over an existing file system.

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

The conditional technique used here is to search (grep) the output of a "report" for the existence of a word or phrase that exists if the command has already been run. In this case if "part1" is included in the output of lsblk -f, then do not create the file system with the label "part1". 
</Deprecated>

So far, Bash shell provisioning techniques have been used here. Chef is generally easier. Idempotence is often handled by default for most Chef resources. If not, guards can be built and the conditional technique described here adapts well to these guards.

Refactor 1-3 has replaced chef_solo with chef_zero. This has allowed (manual so far) inclusion of Chef Supermarket cookbooks.

Chef_zero provisioner block
```
  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.data_bags_path = "data_bags"
    chef.nodes_path = "nodes"
    chef.roles_path = "roles"

    chef.add_recipe "hello_web"
    chef.add_recipe "filesystem"
    chef.add_recipe "fs"
    chef.add_recipe "mountfs"
    chef.add_recipe "tz"
    chef.add_recipe "gui"
    chef.add_recipe "devops-apps"
  end
```

The recipe "filesystem" is from the Chef Supermarket and is a requirement for the fs recipe. to add a Supermarket Cookbook the stupid manual way:
* download tarball from supermarket site (https://supermarket.chef.io)
* to root of Vagrant box that is running
* in Vagrant box cd /vagrant
* tar -xzf [name.tar.gz]
* back in host, copy resultant/expanded cookbook to cookbooks folder
* chef.add_recipe "[name]"

<Deprecated>
To provision with Chef, use the chef_solo provisioner:
```
config.vm.provision "chef_solo" do |chef|
  chef.add_recipe "mountfs"
end
```
</Deprecated>

Create a "cookbooks" folder in the host folder for the Vagrant guest. Then create mountfs\recipes\default.rb under that folder. This cookbook was refactored to use the Chef mount resource.

mountfs recipe
```
package 'vim-enhanced'

directory "part1"
directory "part2"
directory "part3"

# This Chef Resource seems to be a straight replacement for the execute command
# The former, left here commented out for instructional purposes, wrote (appended) 
# lines to fstab. That function is now done with the enable action. Note the fstype
# likely optional as its default is 'auto' and likely detects the existing fs
mount '/part1' do
  device 'part1'
  device_type :label
  action [:mount, :enable]
  fstype 'ext2'
  pass 0
end
# Add partition 1 to fstab if it is not already there (old method)
# execute "add partition1 to fstab" do
#   command "echo 'LABEL=part1\t\t/part1\t\t\text2\tdefaults\t0 0' >> /etc/fstab"
#   not_if 'cat /etc/fstab | /usr/bin/grep part1'
# end

mount '/part2' do
  device 'part2'
  device_type :label
  action [:mount, :enable]
  fstype 'ext3'
  pass 0
end
# Add partition 2 to fstab if it is not already there
# execute "add partition2 to fstab" do
#   command "echo 'LABEL=part2\t\t/part2\t\t\text3\tdefaults\t0 0' >> /etc/fstab"
#   not_if 'cat /etc/fstab | /usr/bin/grep part2'
# end

mount '/part3' do
  device 'part3'
  device_type :label
  action [:mount, :enable]
  fstype 'ext4'
  pass 0
end
# Add partition 3 to fstab if it is not already there
# execute "add partition3 to fstab" do
#   command "echo 'LABEL=part3\t\t/part3\t\t\text4\tdefaults\t0 0' >> /etc/fstab"
#   not_if 'cat /etc/fstab | /usr/bin/grep part3'
# end

# This should no longer be necessary as the devices are mounted in the mount resource
# Mount all file systems in fstab
# execute "mount -a"
```

The first three lines of this recipe are Chef resources that will create a directory if it does not already exist. The append to fstab file, plus a mount all command was replaced here.

### Install Gnome gui and VirtualBox Guest extensions
Everything from here is implemented as a Chef recipe via Chef-Solo. So the chef_solo block gets some new lines. The recipes for tz (timezone), ga-dependencies (Guest Additions) and gui (Gnome) are documented in this section

updates to Vagrantfile
```
  config.vm.provision "chef_solo" do |chef|
    .
    .
    .
    chef.add_recipe "tz"
    chef.add_recipe "gui"
    chef.add_recipe "devops-apps"
  end
```

Timezone (tz) simply creates a symbolic link

tz
```
link '/etc/localtime' do
  to '/usr/share/zoneinfo/America/Los_Angeles'
end
```

The Guest Additions dependencies recipe, installs some packages, updates the kernel and appends to the .bashrc file. The bashrc file lines will install the Guest Additions from the iso mounted in the cdrom at the first logon from the gui
* See comments about idempotence
* `package %w(pkg1 pkg2 ...)` will install all of the packages in the list. Like a foreach loop.

<deprecated>
ga-dependencies
```
# gonna need two levels of idempotence
# first, only add lines to the .bashrc file once
#   echo a unique comment to the top of the code block
#   set a guard to not append the lines if the comment exists
# second, the bash script itself has a conditional to prevent the
#   Guest Additions from installing if installed already
execute "add line(s) to installga script" do
    command <<-EOF
      echo '# InstallGuestAdditions' >> /home/vagrant/.bashrc
      echo 'if [ "$(ls /opt | grep 6.0.4)" == "" ]' >> /home/vagrant/.bashrc
      echo 'then' >> /home/vagrant/.bashrc
      echo '  sudo /run/media/vagrant/VBox_GAs_6.0.4/VBoxLinuxAdditions.run 2> /dev/null' >> /home/vagrant/.bashrc
      echo 'fi' >> /home/vagrant/.bashrc
    EOF
    not_if 'cat /home/vagrant/.bashrc | grep InstallGuestAdditions'
  end

package "epel-release"

# This line is effectively idempotent
execute "sudo yum update kernel* -y"

package %w(make gcc perl dkms bzip2 kernel-headers kernel-devel) 
```
</deprecated>

No new concepts in the gui recipe

gui
```
package "kernel-devel"

# multiple commands to install Gnome
execute "install gnome" do
  command <<-EOF
    yum groupinstall -y 'gnome desktop'
    yum install -y 'xorg*'
    yum remove -y initial-setup initial-setup-gui
    systemctl set-default graphical.target
    systemctl isolate graphical.target
  EOF
  not_if 'systemctl get-default | grep graphical'
end
```

# Environment notes
* Windows 10
* Chocolatey
* VirtualBox (installed with choco)
* Vagrant (installed with choco)
* Git (installed with choco)

## Working with VirtualBox/Vagrant/Windows host
* Whenever possible, use the vagrant commands to control a vm
  * `vagrant halt/reload/destroy` to shutdown/reboot/delete
  * If vagrant fails to fully destroy a box. (vagrant up returns error that box already exists) delete the folder for it in C:\Users\[user]\VirtualBox VMs.
  * Race conditions can occur, particularly on a vagrant reload
    * This might be solved by increasing the timeout:
      * `config.vm.boot_timeout = 1200`  --  NO, this does not work
    * Symptoms of race condition are:
      * "Vagrant was unable to mount VirtualBox shared folders..."
      * "...the command attempted was:  mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant"
      * in particular, this occurs after the first vagrant reload post GA install
      * The workaround is to wait until the VM comes up to the gui and vagrant reload a second time

## Git process notes
* Master branch to be used to build extra disk partitions and file systems, then documentation
* Gui branch to build out Gnome and guest additions

### Step One and example
* Add the tz recipe to the Vagrantfile on the gui branch
* Now `vagrant up` will set the timezone when on the gui branch, but not on master.
* Proposed rules
  * Modify the README on the master branch
  * Modify the Vagrantfile on the gui branch
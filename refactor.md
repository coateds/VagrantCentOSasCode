# A log of refactors
Use the chef mount resource to refactor the way I add lines to fstab. If I :enable a mount point, it will add an entry to fstab:  https://docs.chef.io/resource_reference.html  search for "mount resource" or go to https://docs.chef.io/resource_mount.html

## Refactor 1
The mountfs recipe has been updated to use the mount resource instead of appending to the fstab file and running mount -a. Notes for doing that are contained in the recipe file as comments for now.

## Refactor 2
The Guest Additions can be more effectively installed using the vbguest plugin installed on the host
* `vagrant plugin install vagrant-vbguest`
* comment out the ga-dependencies recipe from Vagrantfile

## Refactor 3
Change to Chef Zero, add filesystem supermarket cookbook, replace provision_fs.sh with fs recipe. fs cookbook is dependent on filesystem
* Chef Zero info: https://medium.com/@Joachim8675309/vagrant-provisioning-with-chef-90a2bf724f

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

    # deprecated
    # chef.add_recipe "ga-dependencies"
  end
```

## Refactor 4
Collapse fs and mountfs cookbooks into partitions-filesystems.
* No change to fs cookbook, just move the resources
* move the fs dependency on the filesystem cookbook to the metadata.rb file in the partitions-filesystems cookbook
* Also no change to mountfs code, just move the resources
* include installation of gdisk

## Refactor 5
Add Python3 cookbook which does not run properly AFTER the yum upgrade

## Refactor 6
move system updates to its own cookbook

## Supermarket Cookbooks
* filesystem
* yumgroup

```
  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.data_bags_path = "data_bags"
    chef.nodes_path = "nodes"
    chef.roles_path = "roles"

    # Does not run properly AFTER updates
    chef.add_recipe "python3"
     
    # This cookbook depends on the filesystem cookbook which depends on lvm
    chef.add_recipe "system-updates"
    chef.add_recipe "partitions-filesystems"
    chef.add_recipe "hello_web"
    chef.add_recipe "tz"
    chef.add_recipe "gui"
    chef.add_recipe "devops-apps"

    # dependency handled by metadata.rb
    # chef.add_recipe "filesystem"

    # deprecated
    # chef.add_recipe "ga-dependencies"
    # chef.add_recipe "fs"
    # chef.add_recipe "mountfs"
  end
```

### Add Supermarket Cookbook
Stupid manual way:
* download tarball from supermarket site (https://supermarket.chef.io)
* to root of Vagrant box that is running
* in Vagrant box cd /vagrant
* tar -xzf [name.tar.gz]
* back in host, copy resultant/expanded cookbook to cookbooks folder
* chef.add_recipe "[name]"


Then Try: https://blog.swiftsoftwaregroup.com/how-to-use-berkshelf-chef-zero-vagrant-and-virtualbox

Berksfile
```
source 'https://supermarket.chef.io'
```



CentOS box has shared folder and some python environments I will want to keep. Goal is to transfer that to CentOSGui as my main working GUI CentOS box.

CentOSasCode is now the primary development box for CentOS builds

Doing research into refactoring CentOSasCode
* there is a cookbook for gdisk: https://supermarket.chef.io/cookbooks/gdisk/versions/0.1.2
* in this cookbook there are hints for using Berkshelf: https://github.com/akadoya/gdisk-cookbook/blob/master/Vagrantfile

There is a filesystem cookbook:  https://supermarket.chef.io/cookbooks/filesystem/versions/1.0.0

https://www.bing.com/videos/search?q=chef.recipe_url+vagrant+provision+chef+solo&view=detail&mid=E10B3E208BE4A70E549BE10B3E208BE4A70E549B&FORM=VIRE

## Refactor 7
Move all recipes into centos-as-code cookbook, add attributes and start to log progress/integration tests through the Chef provisioning process.
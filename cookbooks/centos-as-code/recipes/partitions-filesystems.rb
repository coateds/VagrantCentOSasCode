execute 'log header' do
  command <<-EOF
    echo '*********'  >> #{node['log-file']['path']}
    echo 'partitions and filesystems recipe' >> #{node['log-file']['path']}
    echo ''  >> #{node['log-file']['path']}
  EOF
end

package 'gdisk'
package 'vim-enhanced'

# partition creation is not idempotent, but just throws an error if gdisk attempts
# to create a partition over an existing one. Just throw the error away and ignore it.
execute 'create-partitions' do
  command <<-EOF
    sgdisk -n 1:2048:22527 -t 1:8300 /dev/sdb 2> /dev/null
    sgdisk -n 2:$(sgdisk -F /dev/sdb):43007 -t 2:8300 /dev/sdb 2> /dev/null
    sgdisk -n 3:$(sgdisk -F /dev/sdb):63487 -t 3:8300 /dev/sdb 2> /dev/null
  EOF
  ignore_failure true
end

execute 'log partition 1' do
  command <<-EOF
    echo 'partition 1 not created' >> #{node['log-file']['path']}
  EOF
  not_if 'lsblk | grep sdb1'
end

execute 'log partition 2' do
  command <<-EOF
    echo 'partition 2 not created' >> #{node['log-file']['path']}
  EOF
  not_if 'lsblk | grep sdb2'
end

execute 'log partition 3' do
  command <<-EOF
    echo 'partition 3 not created' >> #{node['log-file']['path']}
  EOF
  not_if 'lsblk | grep sdb3'
end

# Depends on filesystem supermarket cookbook
# Create three file systems
filesystem "part1" do
  fstype "ext2"
  device "/dev/sdb1"
  action [:create]
end

filesystem "part2" do
  fstype "ext3"
  device "/dev/sdb2"
  action [:create]
end

filesystem "part3" do
  fstype "ext4"
  device "/dev/sdb3"
  action [:create]
end

# Create the directories for mount points
directory "part1"
directory "part2"
directory "part3"

# mount and enable (adds to fstab)
# Note the "pass 0" sets the number for the last option in the fstab to 0
mount '/part1' do
  device 'part1'
  device_type :label
  action [:mount, :enable]
  fstype 'ext2'
  pass 0
end

mount '/part2' do
  device 'part2'
  device_type :label
  action [:mount, :enable]
  fstype 'ext3'
  pass 0
end

mount '/part3' do
  device 'part3'
  device_type :label
  action [:mount, :enable]
  fstype 'ext4'
  pass 0
end

execute 'log partition 1' do
  command <<-EOF
    echo 'partition 1 not mounted' >> #{node['log-file']['path']}
  EOF
  not_if 'ls /part1 | grep lost+found'
end
  
execute 'log partition 2' do
  command <<-EOF
    echo 'partition 2 not mounted' >> #{node['log-file']['path']}
  EOF
  not_if 'ls /part2 | grep lost+found'
end
  
execute 'log partition 3' do
  command <<-EOF
    echo 'partition 3 not mounted' >> #{node['log-file']['path']}
  EOF
  not_if 'ls /part3 | grep lost+found'
end
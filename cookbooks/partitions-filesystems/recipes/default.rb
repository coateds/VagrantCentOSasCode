package 'gdisk'
package 'vim-enhanced'

# Run patch upgrades and create partitions
# upgrades early in the install is a requirement! The Gnome install fails without it
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
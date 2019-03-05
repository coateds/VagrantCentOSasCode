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
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
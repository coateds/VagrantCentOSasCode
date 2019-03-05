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
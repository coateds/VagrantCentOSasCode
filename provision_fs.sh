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


#! /bin/bash

echo "Disks"
lsblk -f
echo ''
echo ''

echo "partition contents"
ls /part1
ls /part2
ls /part3

echo ''
echo ''

git --version
echo "code version $(code --version)"

echo ''
echo ''

echo "Webpage"
curl -i localhost

echo ''
echo ''

echo "python3 version $(python3 --version)"
echo 

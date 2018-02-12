#!/bin/bash

#mve 20100424
# script does a sequential READ performance test fot he disk by checking the
# speed at different parts of the disk.
# This is only slightly better than doing `hdparm -tT` but for serious tests
# use bonnie++ or fio instead.

# This script should show that for HDD's, the speed will drop as the test
# prgresses, due to the inner part of the platters moving less fast under
# the disks head, thus allowing for a lower throughput.

# configureable. the higher the more precise
steps=20
# size in blocks that will be tested per step. 10240=10MiB.
step_read_size=10240


# script starts here

args=("$@")

echo "way to use: ./diskspeed.sh /dev/sda"

#echo arguments to the shell
echo ${args[0]}

#totaldisksize=`fdisk -l ${args[0]}|grep ${args[0]}|grep bytes|sed 's/.*GB, \(.*\) bytes/\1/g'`
totaldisksize=`fdisk -l ${args[0]}|grep ${args[0]}|grep bytes|sed 's/.\+, \([0-9]\+\) bytes.*/\1/g'`
blocksize=1024

let step_skip_size=(${totaldisksize}/${steps})/${blocksize}

echo "disk is $totaldisksize bytes"
echo "so we'll do 100 sections for blocksize $blocksize bytes is $blockcount blocks per section"

if [ $step_skip_size == "" ]; then
  exit
fi

declare -i skip
skip=0
for i in $(seq 1 $steps); do
  dd skip=$skip count=$step_read_size ibs=$blocksize if=${args[0]} of=/dev/null
  let skip=(${skip}+${step_skip_size})
  #echo $skip;
done



#! /bin/bash
# This checks if the number of arguments is correct
# If the number of arguments is incorrect ( $# != 2) print error message and exit 
if [[ $# != 2 ]]
then
  echo "backup.sh target_directory_name destination_directory_name"
  exit
fi
# This checks if argument 1 and argument 2 are valid directory paths
if [[ ! -d $1 ]] || [[ ! -d $2 ]]
then
  echo "Invalid directory path provided"
  exit
fi
# [TASK 1]
targetDirectory=$1
destinationDirectory=$2
# [TASK 2]
echo "$targetDirectory"
echo "$destinationDirectory"
# [TASK 3]
currentTS=$(date "+%s")
# [TASK 4]
backupFileName="backup-$currentTS.tar.gz"

# We're going to:
  # 1: Go into the target directory
  # 2: Create the backup file
  # 3: Move the backup file to the destination directory

# To make things easier, we will define some useful variables...

# [TASK 5]
origAbsPath=$(pwd)

# [TASK 6]
cd $destinationDirectory
destDirAbsPath=$(pwd)

# [TASK 7]
cd $origAbsPath # <-

cd $targetDirectory # <-
# Math can be done using $(()); for example: zero=$((3 * 5 - 6 - 9))
# [TASK 8]
yesterdayTS=$(($currentTS-24*60*60))
#This line declares a variable called toBackup, which is an array
declare -a toBackup
# declare -a myArray
# myArray+=("Linux")
# myArray+=("is")
# myArray+=("cool!")
# echo $myArray
# Linux is cool!
for file in $(ls) # [TASK 9]
do
  # [TASK 10]
  # To get the last-modified date of a file in seconds
  # use date -r $file +%s
  if [[ $(date -r $file "+%s")>$yesterdayTS ]]
  then
    # [TASK 11]
    toBackup+=($file)
  fi
done

# [TASK 12]
# 壓縮 (兼打包效果)
# tar -zcf [目標檔名（xxx.tar.gz）] [來源檔名]
#echo "$toBackup"
tar -czvf backupFileName.tar $toBackup
# [TASK 13]

mv backupFileName.tar $destDirAbsPath
# Congratulations! You completed the final project for this course!

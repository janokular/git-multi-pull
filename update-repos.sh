#!/bin/bash

# Update repos.txt

repos_file=./repos.txt
repos_dir=~/Repositories
tmp_file=$(mktemp)

# List dir inside repos_dir and add them to tmp_file
basename -a $(ls -d ${repos_dir}/*/) > $tmp_file

# Check if repos_file exists
if [[ -f $repos_file ]]; then
  # Check if repos_file has to be updated
  diff $tmp_file $repos_file &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "$repos_file is up to date"
    rm $tmp_file
    exit 0
  fi
fi

# Update repos_file
cat $tmp_file > $repos_file
rm $tmp_file

exit 0

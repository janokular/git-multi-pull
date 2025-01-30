#!/bin/bash

# This script pulls changes for every repository from a list

REPO_FILE='./repos'

# Check if REPO_FILE exists and is a file
if [[ ! -e "${REPO_FILE}" ]]
then
  echo "Cannot open ${REPO_FILE}" >&2
  exit 1
fi

# Pull changes for every repository from the REPO_FILE
for REPO in $(cat "${REPO_FILE}")
do
  echo "Pulling changes for ${REPO}"
  git -C "${REPO}" pull
  
  # Check the status of the git pull command
  if [[ "${?}" -ne 0 ]]
  then
    echo -e "Failed at pulling changes for ${REPO}\n"
  else
    echo -e "Successfully pulled changes for ${REPO}\n"
  fi
done

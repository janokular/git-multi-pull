#!/bin/bash

# This script pulls changes for every repository from a list

REPO_FILE='./repos'

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check if REPO_FILE exists and is a file
if [[ ! -e "${REPO_FILE}" ]]
then
  echo "Cannot open ${REPO_FILE}" >&2
  exit 1
fi

# Pull changes for every repository from the REPO_FILE
for REPO in $(cat "${REPO_FILE}")
do
  BASE_REPO=$(basename ${REPO})
  echo "Pulling changes for ${BASE_REPO}"
  git -C "${REPO}" pull
  
  # Check the status of the git pull command
  if [[ "${?}" -ne 0 ]]
  then
    echo -e "${RED}Failed at pulling changes for ${BASE_REPO}${NC}\n"
  else
    echo -e "${GREEN}Successfully pulled changes for ${BASE_REPO}${NC}\n"
  fi
done
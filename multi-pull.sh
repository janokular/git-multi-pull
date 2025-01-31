#!/bin/bash

# This script pulls changes for every repository from a list

REPO_FILE='./repos'

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
  echo "Pulls changes to all listed repositories"
  echo -e "[-f FILE]\tUse FILE for the list of repositories: default ${REPO_FILE}"
  echo -e "[-v]\t\tVerbose mode: display additional messages"
  exit 1
}

# Check options provided by the user
while getopts f:v OPTION
do
  case ${OPTION} in
    f) REPO_FILE=${OPTARG} ;;
    v) VERBOSE_MODE='true' ;;
    ?) usage ;;
  esac
done

# Check if REPO_FILE exists and is a file
if [[ ! -f "${REPO_FILE}" ]]
then
  echo "Cannot open ${REPO_FILE}" >&2
  exit 1
fi

# Check if REPO_FILE is not empty
if [[ ! -s "${REPO_FILE}" ]]
then
  echo "${REPO_FILE} is empty"
  exit 1
fi

# Pull changes for every repository from the REPO_FILE
for REPO in $(cat "${REPO_FILE}")
do
  BASE_REPO=$(basename ${REPO})
  
  # Check if user wants to get additional messages
  if [[ ${VERBOSE_MODE} = 'true' ]]
  then
    echo "Trying to pull changes for ${BASE_REPO}"
    git -C "${REPO}" pull
  else
    git -C "${REPO}" pull &> /dev/null
  fi
  
  # Check the status of the git pull command
  if [[ "${?}" -ne 0 ]]
  then
    echo -e "${RED}Failed at pulling changes for ${BASE_REPO}${NC}\n"
  else
    echo -e "${GREEN}Successfully pulled changes for ${BASE_REPO}${NC}\n"
  fi
done

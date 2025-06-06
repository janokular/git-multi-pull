#!/bin/bash

# This script pulls changes for every repository from a list

REPO_FILE='./repos'
REPO_PATH='~/Repositories'

usage() {
  echo "Usage: ${0} [-v] [-f FILE]"
  echo "Pull changes for all listed repositories: default ${REPO_FILE}"
  echo -e "-f FILE\tUse FILE for the list of repositories"
  echo -e "-v\tVerbose mode"
  exit 1
}

# Check options provided by the user
while getopts f:v OPTION &> /dev/null
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
  echo -e "Cannot open ${REPO_FILE}" >&2
  exit 1
fi

# Check if REPO_FILE is not empty
if [[ ! -s "${REPO_FILE}" ]]
then
  echo -e "Provided file ${REPO_FILE} is empty" >&2
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
    git -C "${REPO_PATH}/${REPO}" pull
  else
    git -C "${REPO_PATH}/${REPO}" pull &> /dev/null
  fi
  
  # Check the status of the git pull command
  if [[ "${?}" -ne 0 ]]
  then
    echo -e "Failed at pulling changes for ${BASE_REPO}\n"
  else
    echo -e "Successfully pulled changes for ${BASE_REPO}\n"
  fi
done

exit 0

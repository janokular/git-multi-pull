#!/bin/bash

# This script pulls changes for every repository from a list

repo_file='./repos'
repo_path="${HOME}/repositories"

red="\033[0;31m"
green="\033[0;32m"
reset="\033[0m"

usage() {
  echo "Usage: ${0} [-v] [-f FILE]"
  echo "Pull changes for all listed repositories: default ${repo_file}"
  echo -e "-f FILE\tUse FILE for the list of repositories"
  echo -e "-v\tVerbose mode"
  exit 1
}

# Check options provided by the user
while getopts f:v option &> /dev/null; do
  case ${option} in
    f) repo_file=${OPTARG} ;;
    v) verbose_mode='true' ;;
    ?) usage ;;
  esac
done

# Check if repo_file exists and is a file
if [[ ! -f "${repo_file}" ]]; then
  echo "Cannot open ${repo_file}" >&2
  exit 1
fi

# Check if repo_file is not empty
if [[ ! -s "${repo_file}" ]]; then
  echo "Provided file ${repo_file} is empty" >&2
  exit 1
fi

# Pull changes for every repository from the repo_file
for repo in $(cat "${repo_file}"); do
  base_repo=$(basename ${repo})
  
  # Check if user wants to get additional messages
  if [[ ${verbose_mode} = 'true' ]]; then
    echo "Trying to pull changes for ${base_repo}"
    git -C "${repo_path}/${repo}" pull
  else
    git -C "${repo_path}/${repo}" pull &> /dev/null
  fi
  
  # Check the status of the git pull command
  if [[ "${?}" -ne 0 ]]; then
    echo -e "${red}Failed at pulling changes for ${base_repo}${reset}\n"
  else
    echo -e "${green}Successfully pulled changes for ${base_repo}${reset}\n"
  fi
done

exit 0

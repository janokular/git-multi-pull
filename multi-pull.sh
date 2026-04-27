#!/bin/bash

# This script pulls changes for every repository from a list

repo_file='./repos.txt'
repo_path="${HOME}/Repositories"

red="\033[0;31m"
green="\033[0;32m"
reset="\033[0m"

usage() {
  echo "Usage: ${0} [-f FILEPATH] [-u] [-v]"
  echo "Pull changes for all listed repositories: default ${repo_file}"
  echo -e "-f FILEPATH\tUse external file with list of repositories"
  echo -e "-u\t\tUpdate ${repo_file} with repositories in ${repo_path}"
  echo -e "-v\t\tVerbose mode"
  exit 1
}

# Check options provided by the user
while getopts f:uv option &> /dev/null; do
  case ${option} in
    f) repo_file=${OPTARG} ;;
    u) update_repos='true' ;;
    v) verbose_mode='true' ;;
    ?) usage ;;
  esac
done

# Update repo_file
if [[ ${update_repos} = 'true' ]]; then
  tmp_file=$(mktemp)
  basename -a $(ls -d ${repo_path}/*/) > $tmp_file
  
  # Check if repos_file exists and if it has to be updated
  if [[ -f $repo_file ]] \
  && diff $tmp_file $repo_file &> /dev/null; then
    echo -e "${yellow}Already up to date: ${repo_file}${reset}\n"
  else
    cat $tmp_file > $repo_file

    # Check the status of the git pull command
    if [[ "${?}" -ne 0 ]]; then
      echo -e "${red}Failed at updating ${repo_file}${reset}\n"
    else
      echo -e "${green}Successfully updated ${repo_file}${reset}\n"
    fi
  fi

  rm $tmp_file
fi

# Check if repo_file exists and is a file
if [[ ! -f "${repo_file}" ]]; then
  echo "Provided file ${repo_file} deos not exist" >&2
  exit 1
# Check if repo_file is not empty
elif [[ ! -s "${repo_file}" ]]; then 
  echo "Provided file ${repo_file} is empty" >&2
  exit 1
fi

# Pull changes for every repository from the repo_file
for repo in $(cat "${repo_file}"); do
  # Check if user wants to get additional messages
  if [[ ${verbose_mode} = 'true' ]]; then
    git -C "${repo_path}/${repo}" pull
  else
    git -C "${repo_path}/${repo}" pull &> /dev/null
  fi
  
  # Check the status of the git pull command
  if [[ "${?}" -ne 0 ]]; then
    echo -e "${red}Failed at pulling changes for ${repo}${reset}\n"
  else
    echo -e "${green}Successfully pulled changes for ${repo}${reset}\n"
  fi
done

exit 0

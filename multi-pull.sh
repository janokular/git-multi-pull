#!/bin/bash

# This script pulls changes for every repository from a list

repo_file='./repos.txt'
repo_path="${HOME}/Repositories"

function usage() {
  echo "usage: $(basename ${0}) [-c] [-f FILEPATH] [-h] [-u] [-v]"
  echo -e "\nPull changes for all repositories listed inside ${repo_file}\n"
  echo -e "-c\t\tenable colorized output"
  echo -e "-f FILEPATH\tuse external file with list of repositories"
  echo -e "-h\t\tshow this help message and exit"
  echo -e "-u\t\tupdate repository file ${repo_file} and exit"
  echo -e "-v\t\tverbose mode"
  exit 1
}

function update_repo_file() {
  local repo_file='./repos.txt'
  local tmp_file=$(mktemp)

  # Override the tmp_file only with directories inside repo_path
  basename -a $(ls -d ${repo_path}/*/) > $tmp_file
  
  # Check if repo_file exists and if it has to be updated
  if [[ -f $repo_file ]] \
  && diff $tmp_file $repo_file &> /dev/null; then
    echo "Already up to date"
  else
    cat $tmp_file > $repo_file

    # Check the update exit code
    if [[ "${?}" -ne 0 ]]; then
      echo -e "${red}Failed at updating ${repo_file}${reset}" >&2
      exit 1
    elif [[ ${verbose_mode} = 'true' ]]; then
      echo -e "${green}Successfully updated ${repo_file}${reset}"
    fi
  fi

  rm $tmp_file
  exit 0
}

# Check options provided by the user
while getopts cf:huv option &> /dev/null; do
  case ${option} in
    c)
      red="\033[0;31m"
      green="\033[0;32m"
      reset="\033[0m"
      ;;
    f) repo_file=${OPTARG} ;;
    h) usage ;;
    u) update_repo_file ;;
    v) verbose_mode='true' ;;
    ?) usage ;;
  esac
done

# Check if repo_file exists
if [[ ! -f "${repo_file}" ]]; then
  echo -e "${red}Provided file ${repo_file} does not exist${reset}" >&2
  exit 1
# Check if repo_file is not empty
elif [[ ! -s "${repo_file}" ]]; then 
  echo -e "${red}Provided file ${repo_file} is empty${reset}" >&2
  exit 1
fi

# Pull changes for every repository listed inside repo_file
for repo in $(cat "${repo_file}"); do
  git -C "${repo_path}/${repo}" pull &> /dev/null
  
  # Check the git pull exit code
  if [[ "${?}" -ne 0 ]]; then
    echo -e "${red}Failed at pulling changes for ${repo}${reset}" >&2
    exit 1
  elif [[ ${verbose_mode} = 'true' ]]; then
    echo -e "${green}Successfully pulled changes for ${repo}${reset}"
  fi
done

exit 0

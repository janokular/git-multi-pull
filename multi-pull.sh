#!/bin/bash

# This script pulls changes for all repositories inside ./repos.txt

repos_file="./repos.txt"
repo_path="${HOME}/Repositories"

function usage() {
  echo "usage: $(basename ${0}) [-c] [-h] [-u] [-v]"
  echo -e "\nPull changes for all repositories inside ${repos_file}\n"
  echo -e "-c\tenable colorized output"
  echo -e "-h\tshow this help message and exit"
  echo -e "-u\tupdate repository file ${repos_file} and exit"
  echo -e "-v\tenable verbose mode"
  exit 1
}

function check_file_exists_and_not_empty() {
  local file="${1}"

  if [[ ! -f "${file}" ]]; then
    echo -e "${red}File ${file} does not exist${reset}" >&2
    exit 1
  elif [[ ! -s "${repos_file}" ]]; then 
    echo -e "${red}File ${file} is empty${reset}" >&2
    exit 1
  fi
}

function update_repos_file() {
  local file="${1}"
  local tmp_file=$(mktemp)

  # Override the tmp_file only with directories in repo_path
  basename -a $(ls -d ${repo_path}/*/) > $tmp_file
  
  if [[ -f "${file}" ]] \
  && diff "${tmp_file}" "${1}" &> /dev/null; then
    echo "Already up to date"
  else
    cat "${tmp_file}" > "${file}"

    if [[ "${?}" -ne 0 ]]; then
      echo -e "${red}Failed at updating ${file}${reset}" >&2
      exit 1
    elif [[ "${verbose}" = "true" ]]; then
      echo -e "${green}Successfully updated ${file}${reset}"
    fi
  fi

  rm "${tmp_file}"
  exit 0
}

function pull_changes() {
  for repo in $(cat "${repos_file}"); do
    git -C "${repo_path}/${repo}" pull &> /dev/null

    if [[ "${?}" -ne 0 ]]; then
      echo -e "${red}Failed at pulling changes for ${repo}${reset}" >&2
      exit 1
    elif [[ "${verbose}" = "true" ]]; then
      echo -e "${green}Successfully pulled changes for ${repo}${reset}"
    fi
  done
}

while getopts "chuv" option &> /dev/null; do
  case "${option}" in
    c)
      readonly red="\033[0;31m"
      readonly green="\033[0;32m"
      readonly reset="\033[0m"
      ;;
    h) usage ;;
    u) update_repos="true" ;;
    v) verbose="true" ;;
    ?) usage ;;
  esac
done

check_file_exists_and_not_empty "${repos_file}"

if [[ "${update_repos}" = "true" ]]; then
  update_repos_file "${repos_file}"
fi

pull_changes "${repos_file}"

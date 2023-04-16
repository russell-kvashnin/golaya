#!/bin/bash
#
# Golaya CLI tool installer

set -euo pipefail

EXECUTABLE_NAME="golaya"
EXECUTABLE_TMP_NAME="$EXECUTABLE_NAME-"$(date +"%s")
EXECUTABLE_DIR=""
DEFAULT_EXECUTABLE_DIR="${HOME}/.golaya/bin"

USER_BIN_DIRS=(
  "${HOME}"/bin
  "${HOME}"/.local/bin
)

IS_USR_DIR_IN_PATH=true

DOWNLOAD_URL="https://gist.githubusercontent.com/russell-kvashnin/acd9d71823dc36d1ee7670a9108a6751/raw/c47dd62cbe3b393cbb80f40fcef0000a1ae5e17d/golaya.sh"

downloader=""

#######################################
# Check file download availability
# Globals:
#   downloader
# Arguments:
#   Passed arguments
#######################################
function check_downloader {
  echo "Checking file download availability..."

  if command -v curl >/dev/null 2>&1; then
      downloader="curl"
  elif command -v wget >/dev/null 2>&1; then
      downloader="wget"
  else
      echo "You must have cURL or wget installed. Exiting."
      exit 1
  fi

  readonly downloader

  echo "${downloader} selected for download."
}

#######################################
# Download latest script version.
# Globals:
#   DOWNLOAD_URL
# Arguments:
#   None
#######################################
function download {
  echo "Downloading executable..."

  case $downloader in
      "curl")
          curl --fail --location "${DOWNLOAD_URL}" > "/tmp/${EXECUTABLE_TMP_NAME}"
          ;;
      "wget")
          wget -q --show-progress "${DOWNLOAD_URL}" -O "/tmp/${EXECUTABLE_TMP_NAME}"
          ;;
  esac

  exit_if_error $? "Download failed. Exiting."

  echo "Done."
}

function prepare_install_dir {
  for usrBinDir in "${USER_BIN_DIRS[@]}"; do
    if [[ ":$PATH:" == *":${usrBinDir}:"* && -d "${usrBinDir}" ]]; then
        echo "User executables directory found and selected for installation: ${usrBinDir}"

        EXECUTABLE_DIR=$usrBinDir

        break
    fi
  done

  if [[ "${EXECUTABLE_DIR}" == "" ]]; then
    echo "Failed to find default user binary directory. Proceed with ${DEFAULT_EXECUTABLE_DIR}"

    EXECUTABLE_DIR=$DEFAULT_EXECUTABLE_DIR
    IS_USR_DIR_IN_PATH=false

    if [ ! -d "${EXECUTABLE_DIR}" ]; then
      echo "Directory ${EXECUTABLE_DIR} is missing, creating."

      mkdir -p "$EXECUTABLE_DIR"
      exit_if_error $? "Failed to create ${EXECUTABLE_DIR}. Exiting"
    fi
  fi
}

function install_executable {
  echo "Installing executable into $EXECUTABLE_DIR ..."

  mv "/tmp/${EXECUTABLE_TMP_NAME}" "${EXECUTABLE_DIR}"/"${EXECUTABLE_NAME}"
  exit_if_error $? "Failed to move executable. Exiting."

  chmod +x "${EXECUTABLE_DIR}"/"${EXECUTABLE_NAME}"
  exit_if_error $? "Failed to make script executable. Exiting."

  echo "Done."
}

function exit_if_error {
  if [ 0 -ne "$1" ]; then
    echo "$2" >&2

    exit 1
  fi
}

function display_post_install_message {
  echo "-----------------------------------------------------------------"
  echo "Installation succesfull."
  echo "Executable is on ${EXECUTABLE_DIR}/${EXECUTABLE_NAME}"

  if ! "${IS_USR_DIR_IN_PATH}"; then
    echo "Do not forget: export PATH=${EXECUTABLE_DIR}:\$PATH"
  fi

  echo "Enjoy."
  echo "-----------------------------------------------------------------"
}

#######################################
# Starts installation process.
# Globals:
#   None
# Arguments:
#   None
#######################################
function main {
  echo "Golaya installation."

  check_downloader

  download

  prepare_install_dir

  install_executable

  display_post_install_message

  exit 0
}

main


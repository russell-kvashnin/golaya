#!/bin/bash
#
# Golaya CLI tool installer

set -euo pipefail

EXECUTABLE_NAME="golaya"
EXECUTABLE_TMP_NAME="$EXECUTABLE_NAME-"$(date +"%s")
EXECUTABLE_DIR="${HOME}/.local/bin"
DOWNLOAD_URL="https://gist.githubusercontent.com/russell-kvashnin/acd9d71823dc36d1ee7670a9108a6751/raw/c47dd62cbe3b393cbb80f40fcef0000a1ae5e17d/golaya.sh"
EXECUTABLE_DEST="${EXECUTABLE_DIR}/${EXECUTABLE_NAME}"

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

function install_executable {
  echo "Installing executable into $EXECUTABLE_DIR ..."

  mv "/tmp/${EXECUTABLE_TMP_NAME}" "${EXECUTABLE_DEST}"
  exit_if_error $? "Failed to move executable. Exiting."

  chmod +x "${EXECUTABLE_DEST}"
  exit_if_error $? "Failed to make script executable. Exiting."

  echo "Done."
}

function exit_if_error {
  if [ 0 -ne "$1" ]; then
    echo "$2" >&2

    exit 1
  fi
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

  install_executable

  echo "Installation successful."
}

main

#!/bin/bash
#
# Create new golang project with golang-standards project layout.

set -e

declare -a FULL_DIR_LAYOUT=(
  "api"
  "assets"
  "build"
  "cmd"
  "configs"
  "deployments"
  "docs"
  "examples"
  "githooks"
  "init"
  "internal"
  "pkg"
  "scripts"
  "test"
  "third_party"
  "tools"
  "web"
  "website"
)
readonly FULL_DIR_LAYOUT

declare -a MINIMAL_DIR_LAYOUT=(
  "api"
  "cmd"
  "deployments"
  "docs"
  "internal"
  "pkg"
)
readonly MINIMAL_DIR_LAYOUT

declare -A DEFAULT_FILES
DEFAULT_FILES[".dockerignore"]=$(cat <<EOF
###< developer related stuff ###
.idea/
###> developer related stuff ###

###< project related files ###
.gitignore
Makefile
README.md
###> project related files ###
EOF
)
DEFAULT_FILES[".gitignore"]=$(cat <<EOF
###< developer related stuff ###
.idea/
###> developer related stuff ###

###< project related files ###
vendor/
###> project related files ###
EOF
)
DEFAULT_FILES["Dockerfile"]=$(cat <<EOF
EOF
)
DEFAULT_FILES["go.mod"]=$(cat <<EOF
module github.com/you-vendor/your-app
EOF
)
DEFAULT_FILES["Makefile"]=$(cat <<EOF
EOF
)
DEFAULT_FILES["README.md"]=$(cat << EOF
EOF
)
readonly DEFAULT_FILES

# Set default vars
layoutTemplateName="minimal"
projectName=""
forceCleanup=false

#######################################
# Print usage information.
# Globals:
#   None
# Arguments:
#   None
#######################################
function print_usage {
  cat <<EOF
Golaya - golang project initializer
Initialize new golang project with https://github.com/golang-standards/project-layout structure

Just run:
  golaya my_awesome_project

Usage:
  --help | -h           Display this message
  --full | f            Initialize new project with full layout
  --cleanup | c         Cleanup project directory if exists
EOF
}

#######################################
# Parse arguments passed to command.
# Globals:
#   layoutTemplateName
#   forceCleanup
#   projectName
# Arguments:
#   Passed arguments
#######################################
function parse_args {
  args=$(getopt -o fhc --long full,help,cleanup -- "$@")
  eval set -- "$args"

  while true; do
    case "$1" in
    -h | --help)
      print_usage
      exit 0
      ;;
    -f | --full)
      layoutTemplateName="full"
      readonly layoutTemplateName
      shift
      ;;
    -c | --cleanup)
      forceCleanup=true
      readonly forceCleanup
      shift
      ;;
    --)
      shift
      projectName=$1
      readonly projectName
      break
      ;;
    esac
  done

  if [ "$projectName" == "" ]; then
    print_usage
    exit 2
  fi
}

#######################################
# Creates new project folder structure.
# Globals:
#   projectName
# Outputs:
#   Log to STDOUT
# Arguments:
#   Directories array to create
#######################################
function create_folder_structure {
  echo "Creating directory structure."

  for dirName in "$@"; do
    local filePath
    filePath="$(printf "%s/%s" "$projectName" "$dirName")"

    mkdir -p "$filePath"
    exit_if_error $? "Error while creating [$filePath] directory. Exiting."
  done
}

#######################################
# Add default files from preseted list and populate it with content.
# Globals:
#   projectName
#   DEFAULT_FILES
# Outputs:
#   Log to STDOUT
# Arguments:
#   Files array to create
#######################################
function add_default_files {
  echo "Adding default files."

  for fileName in "${!DEFAULT_FILES[@]}"; do
    local filePath
    filePath="$(printf "%s/%s" "$projectName" "$fileName")"

    touch "$filePath"
    exit_if_error $? "Error while adding [$filePath] file. Exiting."

    echo "${DEFAULT_FILES[$fileName]}" >>"$filePath"
    exit_if_error $? "Error while populating [$filePath] file. Exiting."
  done
}

#######################################
# Cleanup created folders.
# Globals:
#   projectName
# Outputs:
#   Log to STDOUT
# Arguments:
#   None
#######################################
function cleanup {
  echo "Cleaning up."

  rm -rf "$projectName"
}

#######################################
# Check function result, log error and exit if needed.
# Globals:
#   None
# Outputs:
#   Error message to STDERR
# Arguments:
#   Function execution result
#   Error message
#######################################
function exit_if_error {
  if [ 0 -ne "$1" ]; then
    echo "$2" >&2

    exit 1
  fi
}

#######################################
# Main function.
#   - create project folder
#   - create inner folder structure
#   - add and populate some preseted files
# Globals:
#   layoutTemplateName
#   forceCleanup
#   projectName
# Outputs:
#   Log to STDOUT
# Arguments:
#   Passed arguments
#######################################
function main {
  echo "Initializing project: $projectName with template: $layoutTemplateName."

  if [ -d "$projectName" ]; then
    if [ true = "$forceCleanup" ]; then
      cleanup
    else
      echo "Directory [$projectName] already exists. Provide -c or --cleanup arg for force cleanup."

      exit 0
    fi
  fi

  case $layoutTemplateName in
  minimal)
    create_folder_structure "${MINIMAL_DIR_LAYOUT[@]}"
    ;;
  full)
    create_folder_structure "${FULL_DIR_LAYOUT[@]}"
    ;;
  *)
    err "Wrong directory layout template [$layoutTemplateName]. Exiting."
    exit 1
    ;;
  esac

  add_default_files

  echo "Done."

  exit 0
}

parse_args "$@"

main

#!/bin/bash -u

function drush() {
  local root_dir=''

  # Parse options
  while getopts "r:" opt; do
    case $opt in
      r)
        root_dir=$OPTARG
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        return 1
        ;;
    esac
  done

  shift $((OPTIND - 1))

  # Start at the current directory or the specified root directory
  if [[ -n "$root_dir" ]]; then
    dir="$root_dir"
  else
    dir=$PWD
  fi

  # While not at the root (/)
  while [[ "$dir" != "/" ]]; do
    # If vendor/bin/drush exists, run it
    if [[ -x "$dir/vendor/bin/drush" ]]; then
      "$dir/vendor/bin/drush" "$@"
      return
    fi
    # Go up one directory level
    dir=$(dirname "$dir")
  done

  echo "Could not find drush in any parent directory."
  return 1
}

drush "$@"

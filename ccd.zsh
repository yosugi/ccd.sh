#!/usr/bin/env zsh

# ccd - improved cd wrapper with fzf and in-memory bookmarks
# Author : yosugi (modified)
# License: MIT
# Version: 0.2.0

CCD_VERSION="0.2.0"
CCD_FINDER=${CCD_FINDER:-fzf}

# in-memory bookmarks (session only)
typeset -gA CCD_BOOKMARKS

function ccd() {
  local input="$1"
  local selected dir

  case "$input" in
    -h|--help)
      cat <<EOF
Usage: ccd [PATH|...|--]

  ccd path/to/dir/.       - select from subdirs
  ccd path/to/dir/..      - select from subdirs (recursive)
  ccd path/to/file        - cd to the file's parent
  find ... | ccd          - select from stdin
  ccd ...                 - select from parent directories
  ccd --                  - select from directory history
  ccd -h, --help          - show this help message
  ccd -v, --version       - show version

  # bookmarks (in-memory, session only)
  ccd -a, --add [NAME] PATH   - add bookmark (name optional)
  ccd -d, --del NAME          - delete bookmark
  ccd -l, --list              - list bookmarks
  ccd -b, --bm                - select bookmark via fzf
  ccd NAME                    - jump to bookmark if exists

Environment:
  CCD_FINDER                 - command used to select (default: fzf)
EOF
      return
      ;;
    -v|--version)
      echo "ccd version $CCD_VERSION"
      return
      ;;
    -a|--add)
      local name="$2"
      local path="$3"

      # Shorthand: ccd -a /path/to/dir → auto-generate name
      if [[ -n "$name" && -z "$path" ]]; then
        path="$name"
        local i=1
        while [[ -n "${CCD_BOOKMARKS[bm$i]}" ]]; do
          ((i++))
        done
        name="bm$i"
      fi

      if [[ -z "$name" || -z "$path" ]]; then
        echo "Usage: ccd -a [NAME] PATH"
        return 1
      fi

      CCD_BOOKMARKS["$name"]="$path"
      echo "Registered '$name' → $path"
      return
      ;;
    -d|--del)
      local name="$2"
      if [[ -z "$name" ]]; then
        echo "Usage: ccd -d NAME"
        return 1
      fi
      unset "CCD_BOOKMARKS[$name]"
      echo "Deleted '$name'"
      return
      ;;
    -l|--list)
      for name in "${(@k)CCD_BOOKMARKS}"; do
        echo "$name → ${CCD_BOOKMARKS[$name]}"
      done
      return
      ;;
    -b|--bm)
      if (( ${#CCD_BOOKMARKS} == 0 )); then
        echo "No bookmarks."
        return 1
      fi
      selected=$(
        for name in "${(@k)CCD_BOOKMARKS}"; do
          echo "[$name] ${CCD_BOOKMARKS[$name]}"
        done | eval "$CCD_FINDER"
      )
      if [[ -n "$selected" ]]; then
        dir="${selected#*\] }"
        builtin cd "$dir"
      fi
      return
      ;;
  esac

  # stdin mode
  if [[ ! -t 0 ]]; then
    selected=$(cat - | eval "$CCD_FINDER")
    if [[ -n "$selected" ]]; then
      [[ -d "$selected" ]] || selected=$(dirname "$selected")
      builtin cd "$selected"
    fi
    return
  fi

  # bookmark jump
  if [[ -n "$input" && -n "${CCD_BOOKMARKS[$input]}" ]]; then
    builtin cd "${CCD_BOOKMARKS[$input]}"
    return
  fi

  case "$input" in
    '')
      builtin cd ~
      ;;
    '...')
      selected=$(pwd | _ccd-parents | eval "$CCD_FINDER")
      [[ -n "$selected" ]] && builtin cd "$selected"
      ;;
    '--')
      selected=$(dirs -v | awk '{print $2}' | awk '!a[$0]++' | eval "$CCD_FINDER")
      [[ -n "$selected" ]] && builtin cd "$selected"
      ;;
    */..)
      dir="${input%/..}"
      selected=$(find "$dir" -type d 2>/dev/null | eval "$CCD_FINDER")
      [[ -n "$selected" ]] && builtin cd "$selected"
      ;;
    */.)
      dir="${input%/.}"
      selected=$(find "$dir" -maxdepth 1 -type d 2>/dev/null | eval "$CCD_FINDER")
      [[ -n "$selected" ]] && builtin cd "$selected"
      ;;
    *)
      if [[ -d "$input" ]]; then
        builtin cd "$input"
      else
        dir=$(dirname "$input")
        [[ -d "$dir" ]] && builtin cd "$dir"
      fi
      ;;
  esac
}

function _ccd-parents() {
  local dir=$(cat -)
  while [[ "$dir" != "/" ]]; do
    echo "$dir"
    dir=$(dirname "$dir")
  done
  echo "/"
}

#!/bin/bash

error() {
  echo "error: $1, aborting"
  exit 1
}

require_brew() {
  command -v brew >/dev/null && return
  read -r -p "Install homebrew (required)? (y/n)" answer
  case ${answer:0:1} in
  y | Y)
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ;;
  *)
    error "homebrew required"
    ;;
  esac
}

require_brew_dep() {
  command -v $dep >/dev/null && return
  dep="$1"
  read -r -p "Install missing $dep (required)? (y/n)" answer
  case ${answer:0:1} in
  y | Y)
    brew install $dep
    ;;
  *)
    error "$dep required"
    ;;
  esac
}

require_brew
brew_deps=(vim rg fzf bat)
for dep in ${brew_deps[@]}; do
  require_brew_dep $dep
done

note_path=${NOTE_PATH:=$HOME/notes}
mkdir -p -v "$note_path" || error "could not create $note_path"
cd "$note_path" || error "$note_path does not exist"

if [ $# -eq 0 ]; then
  ref=$(rg --line-number --color=always --with-filename --follow . --field-match-separator ' ' |
    fzf --ansi --preview "bat --color=always {1} --highlight-line {2}" |
    head -n1 | awk '{print $1 " +" $2;}')

  if [[ "$ref" ]]; then
    vim $ref
  fi

  exit 0
fi

note_title="$*"
note_filename="$(gdate -I)_${note_title// /-}.md"

touch "$note_filename"
echo "$note_filename"
echo "# $note_title" >"$note_filename"
echo "" >>"$note_filename"
echo "" >>"$note_filename"
vim "$note_filename" +3

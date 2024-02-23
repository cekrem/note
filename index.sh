#!/bin/bash

error() {
	echo "error: $1, aborting"
	exit 1
}

confirm_or_fail() {
	read -r -p "$1" answer
	case ${answer:0:1} in
	y | Y) ;;

	*)
		error "$2"
		;;
	esac
}

require_brew() {
	command -v brew >/dev/null && return
	confirm_or_fail "install homebrew? (y/n)" "can't install missing dependencies without homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
}

require_dep() {
	command -v "$dep" >/dev/null && return
	dep="$1"
	confirm_or_fail "$dep is not installed or not in PATH, install $dep using homebrew? (y/n)" "$dep required"
	require_brew
	brew install "$dep" || exit 1
}

deps=(rg fzf bat)
for dep in "${deps[@]}"; do
	require_dep "$dep"
done

proper_vim=$(command -v nvim || command -v vim || error "neither vim nor nvim found in PATH")

note_path=${NOTE_PATH:=$HOME/notes}
mkdir -p -v "$note_path" || error "could not create $note_path"
cd "$note_path" || error "$note_path does not exist"

if [ $# -eq 0 ]; then
	ref=$(rg --line-number --color=always --with-filename --follow . --field-match-separator ' ' |
		fzf --ansi --preview "bat --color=always {1} --highlight-line {2}" |
		head -n1 | awk '{print $1 " +" $2;}')

	if [[ "$ref" ]]; then
		# shellcheck disable=SC2086
		$proper_vim $ref # intentional word split: `[filename] +[line_number]`
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
$proper_vim "$note_filename" +3

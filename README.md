# Install

`npm install -g ripnote` or `yarn global add ripnote` installs `ripnote` (and the `rn` alias) globally.

# Dependencies

Ripnote requires ripgrep, fzf and bat; these can all be automatically installed using homebrew upon first ripnote launch.

# Create new note

`ripnote "my great note"`

The above command creates `[note-path]/2022-08-03_my-great-note.md` with a `# my great note` heading, and opens the file in `vim` on line 3; ready to take notes ever so quickly.

# Open existing notes

`ripnote`

The above command launches an ultra-fast fuzzy search of your note directory, and opens the selected note in vim.

# Options

You can override `NOTE_PATH` (default `~/notes`). That's it.

# Screenshot

![screenshot](screenshot.gif)

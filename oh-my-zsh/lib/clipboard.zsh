# System clipboard integration
#
# This file has support for doing system clipboard copy and paste operations
# from the command line in a generic cross-platform fashion.
#
# On OS X and Windows, the main system clipboard or "pasteboard" is used. On other
# Unix-like OSes, this considers the X Windows CLIPBOARD selection to be the
# "system clipboard", and the X Windows `xclip` command must be installed.

# clipcopy - Copy data to clipboard
#
# Usage:
#
#  <command> | clipcopy    - copies stdin to clipboard
#
#  clipcopy <file>         - copies a file's contents to clipboard
#
function clipcopy() {
    emulate -L zsh
    local file=$1
    if (( $+commands[xclip] )); then
        if [[ -z $file ]]; then
            xclip -in -selection clipboard
        else
            xclip -in -selection clipboard $file
        fi
    elif (( $+commands[xsel] )); then
        if [[ -z $file ]]; then
            xsel --clipboard --input
        else
            cat "$file" | xsel --clipboard --input
        fi
    else
        print "clipcopy: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
        return 1
    fi
}

# clippaste - "Paste" data from clipboard to stdout
#
# Usage:
#
#   clippaste   - writes clipboard's contents to stdout
#
#   clippaste | <command>    - pastes contents and pipes it to another process
#
#   clippaste > <file>      - paste contents to a file
#
# Examples:
#
#   # Pipe to another process
#   clippaste | grep foo
#
#   # Paste to a file
#   clippaste > file.txt
function clippaste() {
    emulate -L zsh
    if (( $+commands[xclip] )); then
        xclip -out -selection clipboard
    elif (( $+commands[xsel] )); then
        xsel --clipboard --output
    else
        print "clipcopy: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
        return 1
    fi
}

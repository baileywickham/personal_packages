#!/bin/bash

_wt_completion() {
    local cur prev commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    commands="list rm pull prune main help"

    # Get list of worktree names (strip .wt/ prefix and handle slashes)
    local worktrees=$(git worktree list 2>/dev/null | grep '\.wt/' | awk '{print $1}' | sed 's|.*/\.wt/||' 2>/dev/null)

    # Complete first argument with commands or worktree names
    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "$commands $worktrees" -- "$cur") )
        return 0
    fi

    # Complete second argument based on first argument
    case "$prev" in
        rm|pull)
            # Complete with existing worktree names
            COMPREPLY=( $(compgen -W "$worktrees" -- "$cur") )
            return 0
            ;;
        *)
            # For creating new worktrees, complete with branch names
            if [ $COMP_CWORD -eq 2 ]; then
                local branches=$(git branch -a 2>/dev/null | sed 's/^[* ]*//' | sed 's|remotes/origin/||' | sort -u)
                COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
                return 0
            fi
            ;;
    esac
}

complete -F _wt_completion wt

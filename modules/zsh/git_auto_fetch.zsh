last_git_fetch_repo=""

function auto_git_fetch() {
    # Check if we are inside a git work tree
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local current_repo_path=$(git rev-parse --show-toplevel)

        # Only fetch if we've entered a new repo
        if [[ "$current_repo_path" != "$last_git_fetch_repo" ]]; then
            echo "Git auto-fetch updates.."
            # Run fetch in the background and silence output
            (git fetch --all >/dev/null 2>&1 &!)
            last_git_fetch_repo="$current_repo_path"
        fi
    else
        last_git_fetch_repo=""
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd auto_git_fetch

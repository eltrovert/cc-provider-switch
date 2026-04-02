# bash completion for cc-switch
_cc_switch() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local providers_dir
    local script_dir

    # Find providers dir relative to the script
    if [[ -L "${COMP_WORDS[0]}" ]]; then
        script_dir="$(cd "$(dirname "$(readlink -f "${COMP_WORDS[0]}")")" && pwd)"
    else
        script_dir="$(cd "$(dirname "${COMP_WORDS[0]}")" && pwd)"
    fi
    providers_dir="$script_dir/providers"

    local commands="status list validate check rollback completions help"
    local providers=""

    if [[ -d "$providers_dir" ]]; then
        for f in "$providers_dir"/*.json; do
            [[ -f "$f" ]] && providers+=" $(jq -r '.name' "$f" 2>/dev/null)"
        done
    fi

    if [[ "$prev" == "-p" || "$prev" == "--project" ]]; then
        COMPREPLY=($(compgen -d -- "$cur"))
        return 0
    fi

    if [[ "$prev" == "completions" ]]; then
        COMPREPLY=($(compgen -W "bash zsh" -- "$cur"))
        return 0
    fi

    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "-p --project -v --version -h --help" -- "$cur"))
        return 0
    fi

    COMPREPLY=($(compgen -W "$commands $providers" -- "$cur"))
    return 0
}
complete -F _cc_switch cc-switch

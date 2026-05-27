#compdef cc-switch

_cc_switch() {
    local -a commands providers
    local providers_dir script_dir

    if [[ -L "${words[1]}" ]]; then
        script_dir="$(cd "$(dirname "$(readlink -f "${words[1]}")")" && pwd)"
    else
        script_dir="$(cd "$(dirname "${words[1]:-$0}")" && pwd)"
    fi
    providers_dir="$script_dir/providers"

    commands=('status:Show current provider' 'list:List all providers' 'validate:Validate provider configs' 'check:Health check providers' 'rollback:Undo last switch' 'model:Switch model profile' 'completions:Generate shell completions' 'help:Show help')

    providers=()
    local -a model_profiles
    model_profiles=()
    if [[ -d "$providers_dir" ]]; then
        for f in "$providers_dir"/*.json; do
            [[ -f "$f" ]] && providers+=("$(jq -r '.name' "$f" 2>/dev/null)")
        done
        local cliproxyapi_file="$providers_dir/cliproxyapi.json"
        if [[ -f "$cliproxyapi_file" ]]; then
            for p in $(jq -r '.model_profiles | keys[]' "$cliproxyapi_file" 2>/dev/null); do
                model_profiles+=("$p")
            done
        fi
    fi

    _arguments \
        '(-p --project)'{-p,--project}'[Target project settings]:project path:_directories' \
        '(-m --model)'{-m,--model}'[Switch model profile]:model profile:(($model_profiles))' \
        '(-v --version)'{-v,--version}'[Show version]' \
        '(-h --help)'{-h,--help}'[Show help]' \
        '1:command:(($commands $providers))' \
        '2:arg:->arg'

    case $words[2] in
        completions) _describe 'shell' '(bash zsh)' ;;
        check) _describe 'provider' providers ;;
        model) _describe 'model_profile' "list status $model_profiles" ;;
    esac
}

_cc_switch "$@"

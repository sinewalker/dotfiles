#requires sox for the 'play' command line player

#where I keep my short sounds
export BUZDIR=${HOME}/Audio/buz

#play a sound, or list all the buz sounds if no arg
buz() {
    if [[ -z ${1} ]]; then
        pushd ${BUZDIR}
        ls -F
        popd
        return 1
    fi
    local buz=$(find ${BUZDIR} -name ${1})
    if [[ -d ${buz} ]]; then
        pushd ${buz}
        ls *
        popd > /dev/null
    else
        play ${buz}
    fi
}

#Bash completions
_buz() {
    COMPREPLY=()
    local cur sounds
    cur="${COMP_WORDS[COMP_CWORD]}"
    sounds="$(find ${BUZDIR}|xargs basename)"

    COMPREPLY=( $(compgen -W "${sounds}" -- ${cur}) )
    return 0
}
complete -F _buz buz

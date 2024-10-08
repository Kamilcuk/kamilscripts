# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/users/kamil/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/nomad nomad

complete -o nospace -C /home/kamil/go/bin/nomad nomad

complete -o nospace -C /scratch/kcukrowski/xshared/bin/terraform terraform

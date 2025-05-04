#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# make sure path variable do not have duplicate entries
typeset -U path

skip_global_compinit=1

# Ensure that a non-login, non-interactive shell has a defined environment.
# if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
#     source "${ZDOTDIR:-$HOME}/.zprofile"
# fi

[[ -f "$HOME/.cargo/env" ]] && . $HOME/.cargo/env

# vim: set ft=zsh ff=unix ts=4 sw=4 tw=0 expandtab:
# End of File

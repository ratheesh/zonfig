#
# Defines environment variables.
#
# Authors:
#   Ratheesh <ratheeshreddy@gmail.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# make sure path variable do not have duplicate entries
typeset -U path

skip_global_compinit=1

#
# Platform detection
#

case "$OSTYPE" in
    darwin*)  export ZONFIG_OS="macos"  ;;
    linux*)   export ZONFIG_OS="linux"  ;;
    *)        export ZONFIG_OS="other"  ;;
esac

# Ensure that a non-login, interactive shell has a defined environment.
if [[ "$SHLVL" -le 2 && ! -o LOGIN && -o INTERACTIVE && -s "${ZDOTDIR:-$HOME}/.zprofile" && -z "$__ZPROFILE_SOURCED" ]]; then
    echo "🙤 non-login shell🙦"
    export __ZPROFILE_SOURCED=1
    source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# vim: set ft=zsh ff=unix ts=4 sw=4 tw=0 expandtab:
# End of File

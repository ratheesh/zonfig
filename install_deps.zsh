#!/usr/bin/env zsh

set -o pipefail

echo -n "Installing fzf..."
[[ ! -d "$HOME/.fzf" ]] &&
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &> /dev/null  &&
    $HOME/.fzf/install --key-bindings --no-completion --no-update-rc --no-fish &> /dev/null
[[ $? -neq 0 ]] && echo FAILED! || echo OK!

# End of File

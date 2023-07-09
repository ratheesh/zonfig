#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Ratheesh <ratheeshreddy@gmail.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
    export BROWSER='open'
fi

#
# Editors
#

if (( $+commands[nvim] )); then
    export VISUAL='nvim'
    export EDITOR='nvim'
    export GIT_EDITOR='nvim'
else
    export VISUAL='vim'
    export EDITOR='vim'
    export GIT_EDITOR='vim'
fi

export ALTERNATE_EDITOR=""
# export LESS_TERMCAP_md="$ORANGE"
export MINICOM="-m -c on -w -z"	# start minicom in color
export PAGER="less"

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR=$EDITOR
    export GIT_EDITOR=$GIT_EDITOR
else
    export EDITOR=$EDITOR
    export GIT_EDITOR=$GIT_EDITOR
fi

# misc
export GCC_COLOR="auto"
export TERM="xterm-256color"
export COLORTERM="xterm-256color"

# disable soft flow control
stty ixany
stty ixoff -ixon
#
# Language
#

# if [[ -z "$LANG" ]]; then
export GDM_LANG='en_US.UTF-8'
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
# fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
    $HOME/bin
    $HOME/.local/bin
    $HOME/.autojump/bin
    $HOME/.cargo/bin
    /usr/local/{bin,sbin}
    /{bin,sbin}
    /usr/{bin,sbin}
    /usr/local/{bin,sbin}
    /usr/{bin,sbin}
    $path[@]
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
    export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

#
# Temporary Files
#

if [[ ! -d "$TMPDIR" ]]; then
    export TMPDIR="/tmp/$LOGNAME"
    mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

# common environment variable exports

# generic env setting
export TERMINFO=/lib/terminfo	# required for gdb-tui
export TZ='Asia/Kolkata'; export TZ
export LC_ALL='en_US.UTF-8'

if [[ $(echotc Co) -ge 256 ]]; then
    # 256 color terminals
    export GREP_COLORS="mt=03;04;38;5;2;48;5;234:sl=:cx=:fn=38;5;65:ln=38;5;30:bn=37:se=38;5;198"
else
    export GREP_COLORS='ms=03;04;91:mc=01;33;100:sl=:cx=:fn=94:ln=32:bn=33:se=35'
fi

# autojump configuration
export AUTOJUMP_IGNORE_CASE=1 # ignore case in autojump completion
export AUTOJUMP_AUTOCOMPLETE_CMDS='cp vim make'
# lazy load autojump plugin
# j() {
#     unset -f j
#     [[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && . $HOME/.autojump/etc/profile.d/autojump.sh
#     j "$@"
# }

# configure bat application
if (( $+commands[bat] ));then
    export BAT_CONFIG_PATH="$HOME/bat.conf"
else
    echo "WARN:bat app is not installed!"
fi

# configure fzf plugin
FZF_DEFAULT_OPTS="--no-mouse --height 60% -1 --border --margin=0,1,1,1 --reverse --multi --inline-info --header='-> FZF <-' --prompt='➜  ' --pointer='➦ ' --marker='●'"
if (( $+commands[fd] ));then
    export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --color=never --exclude .git'

    _fzf_compgen_path() {
        fd --hidden --follow --hidden --color=never --exclude ".git" . "$1"
    }

    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
        fd --type d --hidden --follow --color=never --exclude ".git" . "$1"
    }
elif (( $+commands[ag] )); then
    echo 'WARN: fd command not installed!'
    export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
    # export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
else
    echo 'WARN: fd or ag is not installed!'
fi

# export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head $LINES'"
# export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -300'"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -500'"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview='(bat {} || highlight -O ansi -l {} || less -f {}) 2> /dev/null | head -500' --preview-window='right:60%' --bind='f2:toggle-preview,alt-j:preview-down,alt-k:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up'
--color=dark
 --color=fg:#a0a0a0,bg:-1,hl:#df678f
 --color=fg+:#b0b0b0,bg+:#242C44,hl+:#1BB1E7
 --color=info:#e79498,border:#5DADEC,prompt:#d7005f,pointer:#af5fff,marker:#e5c07b,spinner:#af5fff,header:#61afef
"

# Remove the prefix prompt when logged as ratheesh
export DEFAULT_USER=`whoami`

# enable ccache for faster rebuilds
export USE_CCACHE=1

# fasd initialization
if (( $+commands[fasd] )); then
    eval "$(fasd --init auto)"
fi

# thefuck module initialization
if (( $+commands[thefuck] )); then
    eval $(thefuck --alias)
fi

# set neovim listening address
if (( $+commands[nvr] && $+commands[nvim] ));then
    export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
    alias nvr='nvr -s --remote'
fi

# autojump initialization
[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh

# fzf initialization
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load virtualenvwrapper into the shell session.
if (( $+commands[virtualenvwrapper_lazy.sh] )); then
    export VIRTUALENV_USE_DISTRIBUTE=1
    export VIRTUALENV_DISTRIBUTE=1
    # Disable default virtualenv prompt.
    VIRTUAL_ENV_DISABLE_PROMPT=1

    # Python virtualenvwrapper settings
    # Set the directory where virtual environments are stored.
    export WORKON_HOME="$HOME/.virtualenvs"
    export VIRTUALENVWRAPPER_VIRTUALENV_ARGS=''

    # Tell pip to respect virtualenv
    export PIP_RESPECT_VIRTUALENV=true
    export PIP_VIRTUALENV_BASE=$WORKON_HOME

    if [ "$VIRTUALENVWRAPPER_PYTHON" = "" ]
    then
        VIRTUALENVWRAPPER_PYTHON="$(command \which python)"
    fi

    # Don't create *.pyc files by default
    export PYTHONDONTWRITEBYTECODE=1

    source "$commands[virtualenvwrapper_lazy.sh]"
fi

# vim: set ft=zsh ff=unix ts=4 sw=4 tw=0 expandtab:
# End of File

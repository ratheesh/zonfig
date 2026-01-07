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
    export EDITOR=nvim visudo
    export VISUAL=nvim visudo
    export SUDO_EDITOR=nvim
    export GIT_EDITOR=nvim
elif (( $+commands[vim] ));then
    export VISUAL='vim'
    export EDITOR='vim'
    export SUDO_EDITOR='vim'
    export GIT_EDITOR='vim'
else
    export VISUAL='nano'
    export EDITOR='nano'
    export SUDO_EDITOR='nano'
    export GIT_EDITOR='nano'
fi

export ALTERNATE_EDITOR=""
# export LESS_TERMCAP_md="$ORANGE"
export MINICOM="-m -c on -w -z"	# start minicom in color

if [[ -x "$(command -v bat)" ]]; then
	# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export PAGER=less
fi

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR=$EDITOR
    export GIT_EDITOR=$GIT_EDITOR
else
    export EDITOR=$EDITOR
    export GIT_EDITOR=$GIT_EDITOR
fi

# misc
export GCC_COLOR="auto"
export TERM="wezterm"
export COLORTERM="wezterm"

# disable soft flow control
stty ixany
stty ixoff -ixon
#
# Language
#

# if [[ -z "$LANG" ]]; then
# export GDM_LANG='en_US.UTF-8'
# export LANG='en_US.UTF-8'
# export LANGUAGE='en_US.UTF-8'
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
    $HOME/.fzf/bin
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
# export TERMINFO=/lib/terminfo	# required for gdb-tui
# export TZ='Asia/Kolkata'; export TZ
# export LC_ALL='en_US.UTF-8'

# if [[ $(echotc Co) -ge 256 ]]; then
#     # 256 color terminals
#     export GREP_COLORS="mt=03;04;38;5;2;48;5;234:sl=:cx=:fn=38;5;65:ln=38;5;30:bn=37:se=38;5;198"
# else
#     export GREP_COLORS='ms=03;04;91:mc=01;33;100:sl=:cx=:fn=94:ln=32:bn=33:se=35'
# fi

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
if [[ -x "$(command -v fzf)" ]]; then
    export FZF_DEFAULT_OPTS="--height 50% --tmux 60%,50%              \
        --layout reverse --multi --min-height 20+ --border            \
        --header-border horizontal                                    \
        --pointer='➤ ' --marker='•' --prompt='➜  '                    \
        --border-label-pos 1                                          \
        --color 'label:blue'                                          \
        --preview-window 'hidden,right,50%' --preview-border line     \
        --bind 'f2:toggle-preview'"

	export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
	  --info=inline-right                      \
	  --ansi                                   \
	  --layout=reverse                         \
	  --border=rounded                         \
	  --color=border:#283838                   \
	  --color=fg:#c0c0c0                       \
	  --color=header:#73918C                   \
	  --color=bg+:#000000                      \
	  --color=hl+:#ff007c:italic               \
	  --color=hl:#2ac3de                       \
	  --color=info:#545c7e                     \
	  --color=marker:#ff007c                   \
	  --color=pointer:#029456                  \
	  --color=prompt:#D8226C                   \
	  --color=query:#c0caf5:regular            \
	  --color=scrollbar:#5f547d                \
	  --color=separator:#6C8494                \
	  --color=spinner:#ff007c                  \
	"
    export _ZO_FZF_OPTS=$FZF_DEFAULT_OPTS
fi

if (( $+commands[fdfind] ));then
    export FZF_DEFAULT_COMMAND='fdfind --type file --follow --hidden --color=never --exclude .git'

    _fzf_compgen_path() {
        fdfind --hidden --follow --hidden --color=never --exclude ".git" . "$1"
    }

   # Use fdfind to generate the list for directory completion
   _fzf_compgen_dir() {
       fdfind --type d --hidden --follow --color=never --exclude ".git" . "$1"
   }
 elif (( $+commands[ag] )); then
    echo 'WARN: fdfind command not installed!'
    export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
else
    echo 'WARN: fdfind or ag is not installed!'
fi

# Remove the prefix prompt when logged as ratheesh
export DEFAULT_USER=`whoami`

# enable ccache for faster rebuilds
export USE_CCACHE=1

# fasd initialization
if (( $+commands[fasd] )); then
    eval "$(fasd --init auto)"
fi

# set neovim listening address
if (( $+commands[nvr] && $+commands[nvim] ));then
    export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
    alias nvr='nvr -s --remote'
fi

# autojump initialization
[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh || echo "WARN: autojump not installed"

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


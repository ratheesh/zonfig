#ctest --preset linux-coverage-test
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
    export EDITOR=nvim
    export VISUAL=nvim
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

if (( $+commands[bat] )); then
	# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export PAGER=less
fi


# misc
export GCC_COLOR="auto"
export COLORTERM="wezterm"

# disable soft flow control
if [[ -t 0 ]]; then
    stty ixany
    stty ixoff -ixon
fi
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
    $HOME/.local/share/nvim/mason/bin
    $HOME/bin
    $HOME/.local/bin
    $HOME/.fzf/bin
    $HOME/.autojump/bin
    $HOME/.cargo/bin
    $HOME/.opencode/bin
    $HOME/gems/bin/
    /usr/local/{bin,sbin}
    /{bin,sbin}
    /usr/{bin,sbin}
    $path[@]
)

# Conditionally add tool-specific paths only if tools exist
(( $+commands[ruby] )) && path+=($HOME/.local/share/gem/ruby/3.4.0/bin $HOME/gems/bin)
(( $+commands[go] )) && path+=($HOME/go/bin)
(( $+commands[llvm-config] )) && path+=(/usr/lib/llvm-3.6/bin)
(( $+commands[JLinkExe] )) && path+=(/opt/SEGGER/JLink)

# Lazy-load Perl environment only on first use
_perl_load() {
    unfunction perl_profile 2>/dev/null
    export GEM_HOME=$HOME/gems
    PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
    PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
    PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
    PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
    PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
}

# Create a wrapper to load Perl config on first perl use
if (( $+commands[perl] )); then
    perl_profile() { _perl_load; perl_profile "$@" }
fi

export GOPATH=$HOME/go

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

# configure bat application
if (( $+commands[bat] ));then
    export BAT_CONFIG_PATH="$HOME/bat.conf"
fi

# Remove the prefix prompt when logged as ratheesh
export DEFAULT_USER=$(whoami)

# enable ccache for faster rebuilds
export USE_CCACHE=1

# set neovim listening address
if (( $+commands[nvr] && $+commands[nvim] ));then
    export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
fi

# Load virtualenvwrapper into the shell session (async).
if (( $+commands[virtualenvwrapper_lazy.sh] )); then
    export VIRTUALENV_USE_DISTRIBUTE=1
    VIRTUAL_ENV_DISABLE_PROMPT=1

    export WORKON_HOME="$HOME/.virtualenvs"
    export VIRTUALENVWRAPPER_VIRTUALENV_ARGS=''

    if [ "$VIRTUALENVWRAPPER_PYTHON" = "" ]
    then
        VIRTUALENVWRAPPER_PYTHON="$(command which python)"
    fi

    # Don't create *.pyc files by default
    export PYTHONDONTWRITEBYTECODE=1

    # Lazy-load virtualenvwrapper on first use (defer initialization)
    _virtualenv_load() {
        unfunction workon mkvirtualenv rmvirtualenv lsvirtualenv cdvirtualenv 2>/dev/null
        source "$commands[virtualenvwrapper_lazy.sh]"
    }
    workon() { _virtualenv_load; workon "$@" }
    mkvirtualenv() { _virtualenv_load; mkvirtualenv "$@" }
    rmvirtualenv() { _virtualenv_load; rmvirtualenv "$@" }
    lsvirtualenv() { _virtualenv_load; lsvirtualenv "$@" }
    cdvirtualenv() { _virtualenv_load; cdvirtualenv "$@" }
fi

# Initialize fzf - https://github.com/junegunn/fzf
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
    export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS +m"
fi

if (( $+commands[fd] ));then
    export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --color=never --exclude .git'

    _fzf_compgen_path() {
        fd --hidden --follow --hidden --color=never --exclude ".git" . "$1"
    }

   # Use fdfind to generate the list for directory completion
   _fzf_compgen_dir() {
       fd --type d --hidden --follow --color=never --exclude ".git" . "$1"
   }
 elif (( $+commands[ag] )); then
    export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if (( $+commands[fzf] )) && [[ -o interactive ]]; then
    _fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf-init.zsh"
    if [[ ! -f $_fzf_cache || $commands[fzf] -nt $_fzf_cache ]]; then
        mkdir -p "${_fzf_cache:h}"
        fzf --zsh >| $_fzf_cache
    fi
    source $_fzf_cache
    unset _fzf_cache
fi

# fzf-git settings
# Redefine the base function with preview disabled by default
# Redefine this function to change the options
if (( $+commands[fzf-tmux] )); then
  _fzf_git_fzf() {
    fzf-tmux -p80%,60% -- \
      --layout=reverse --multi --height=50% --min-height=20 --border \
      --border-label-pos=2 \
      --color='header:italic:underline,label:blue' \
      --preview-window='hidden' \
      --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' "$@"
  }
fi

# zoxide init
# Configure zoxide to replace cd command
export _ZO_ECHO='1'
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS +m"
if (( $+commands[zoxide] )) && [[ -o interactive ]]; then
    _zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zoxide-init.zsh"
    if [[ ! -f $_zoxide_cache || $commands[zoxide] -nt $_zoxide_cache ]]; then
        mkdir -p "${_zoxide_cache:h}"
        zoxide init zsh --cmd j >| $_zoxide_cache
    fi
    source $_zoxide_cache
    unset _zoxide_cache
fi

# Lazy-load cargo env on first use
_cargo_load() {
    unfunction cargo 2>/dev/null
    . "$HOME/.cargo/env"
}
cargo() { _cargo_load; cargo "$@" }


# colorize output of compatible standard utilities
if (( $+commands[grc] )); then
    alias ping='/usr/bin/grc -s --colour=auto ping'
    alias df='/usr/bin/grc -s --colour=auto df -kh'
    alias ifconfig='/usr/bin/grc -s --colour=auto ifconfig'
    alias route='/usr/bin/grc -s --colour=auto route'
    alias irclog='/usr/bin/grc -s --colour=auto irclog'
    # alias ls='/usr/bin/grc -s --colour=auto ls'
    alias mount='/usr/bin/grc -s --colour=auto mount'
    alias gcc='/usr/bin/grc -s --colour=auto gcc'
    alias cal='/usr/bin/grc -s --colour=auto cal'
    alias ncal='/usr/bin/grc -s --colour=auto ncal -w'
fi

# vim: set ft=zsh ff=unix ts=4 sw=4 tw=0 expandtab:


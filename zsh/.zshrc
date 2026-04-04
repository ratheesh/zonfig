# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#
#
# ------------------
# Initialize modules
# ------------------

#
if [[ ! -o login ]];then
    source $HOME/.zprofile
fi

# Define zim location
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh
(( $+functions[autopair-init] )) && autopair-init

# -----------------
# Zsh configuration
# -----------------
# support for bash completion — loaded lazily on first use of complete/compgen
autoload bashcompinit
complete() { unfunction complete compgen; bashcompinit; complete "$@" }
compgen() { unfunction complete compgen; bashcompinit; compgen "$@" }

# Some basic settings
HISTSIZE=10000 # session history size
SAVEHIST=10000 # saved history
HISTFILE=$HOME/.zshistory # history file
ZLE_RPROMPT_INDENT=0

setopt shwordsplit           # make sure that $arm works fine
setopt multibyte             # Support multibyte support
setopt nobgnice              # run bg jobs at full speed
setopt complete_in_word      # allow tab completion in the middle of a word
setopt always_to_end         # Place cursor at end after completion
setopt append_history        # append
setopt extended_history      # append
setopt hist_ignore_all_dups  # no duplicate
setopt hist_reduce_blanks    # trim blanks
setopt hist_verify           # show before executing history commands
setopt inc_append_history    # add commands as they are typed, dont wait until shell exit
setopt share_history         # share hist between sessions
setopt bang_hist             # !keyword
setopt MULTIOS               # write to multiple files
setopt auto_remove_slash     # self explicit
setopt no_clobber            # clobber on redirect
setopt interactive_comments  # enable interactive comments
setopt aliases               # enable aliases
setopt auto_cd               # if command is a path, cd into it
setopt chase_links           # resolve symlinks
setopt correct               # try to correct spelling of commands
setopt extended_glob         # activate complex pattern globbing
setopt glob_dots             # include dotfiles in globbing
setopt nohashdirs            # avoid having to run `rehash` on each new executable in $PATH
setopt autopushd             # Automatically push new folder during cd command
setopt completealiases       # complete aliases
setopt pushdignoredups       # ignore pushd entries
unsetopt pushdsilent         # print the directory stack after pushd/popd
setopt pushdminus            # use minus navigation for directory stack
setopt alias_func_def        # allow alias with function names
setopt monitor               # Support monitor background jobs

unsetopt print_exit_value    # print return value if non-zero
unsetopt correct_all	     # do not correct all automatically
unsetopt beep                # disable audible bell
unsetopt hist_ignore_space   # ignore space prefixed commands
unsetopt rm_star_silent      # ask for confirmation for `rm *' or `rm path/*'
unsetopt hup                 # no hup signal at shell exit
unsetopt flowcontrol	     # ctr-s/q has not effect now (Thanx!!!)
unsetopt AUTO_NAME_DIRS

# watch=all                  # watch all logins - enabling this will print annoying msgs on terminal
logcheck=30                  # every 30 seconds
WATCHFMT="%n from %M has %a tty%l at %T %W"

autoload -U run-help
autoload run-help-git
# unalias run-help
alias help=run-help

# umask for new folders and files
umask 022

# reset terminal settings if previous terminal instance terminated abnormally
ttyctl -f

# Directories
# zstyle ':completion:*:default' list-colors ''

# List hidden files and folder during completion by default

_comp_options+=(globdots)

# Adjust key timeout (useful for Vi mode on Zsh)
export KEYMAPTIMEOUT=1
export KEYTIMEOUT=1

# turn off ZLE bracketed paste in dumb term
# otherwise turn on ZLE bracketed-paste-magic
if [[ $TERM == dumb ]]; then
    unset zle_bracketed_paste
else
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
fi

# If this is removed, cursor after prompt behave weirdly
[[ $TMUX = "" ]] && export TERM="wezterm"


#
# Input/output
#

# Customize spelling correction prompt.
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
zstyle ':zim:input' double-dot-expand yes

# SSH key management (lazy-loaded)
# Set IDs to lazy-load only on first SSH use
zstyle ':zim:ssh' ids 'id_rsa1' 'id_rsa2' 'id_rsa3'
zstyle ':zim:ssh' lazy yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'
#
# zsh-history-substring-search
#
# history substring search module
HISTORY_SUBSTRING_SEARCH_FUZZY=true
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=true
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=233,fg=220,italic'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=234,fg=196,underline'
for keymap in 'emacs' 'viins' 'vicmd'; do
    bindkey -M ${keymap} "^p" history-substring-search-up
    bindkey -M ${keymap} "^n" history-substring-search-down
done

# Bind j/k in normal mode
bindkey -M vicmd "j" history-substring-search-down
bindkey -M vicmd "k" history-substring-search-up


#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=242'


# ------------------------------
# Post-init module configuration
# ------------------------------

# completions
zstyle ':completion:*' special-dirs false
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} "ma=48;5;244;1"

# zsh auto-suggestions module
for keymap in 'emacs' 'viins' 'vicmd'; do
#     bindkey -M ${keymap} '^ ' my-autosuggest-accept
    bindkey -M ${keymap} '^ ' autosuggest-accept
done

for keymap in  'emacs' 'viins' 'vicmd'; do
   bindkey -M ${keymap} '^o' vi-forward-word
done

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#606060,italic"

# bindkey "^M" accept-line
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_STRATEGY=(history match_prev_cmd)
for keymap in 'emacs' 'viins' 'vicmd'; do
    bindkey -M ${keymap} '^\n' autosuggest-execute
done
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)

# Enable multiselection of items
zmodload zsh/complist
bindkey -M menuselect 'a' accept-and-menu-complete

# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

bindkey -M menuselect '^I' menu-select
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Meta-u to chdir to the parent directory
bindkey -s '\eu' '^Ucd ..; ls^M'

# Unbind Ctrl-g for fzf-git to get working
bindkey -r "^g"

# disable highlighting on paste
zle_highlight+=(paste:none)

# global alias expansion keys
# bindkey '^ ' magic-space          # control-space to bypass completion

# Customize to your needs...
# add custom users for auto completion
users=($USER rreddy "$users")
zstyle ':completion:*' users $users

# Embedded development tools - lazy-load on first use
_embedded_dev_load() {
    unfunction cgdb-xilinx cgdb_fscl cgdb_logicpd cgdb_stm goarm 2>/dev/null
    alias cgdb-xilinx='cgdb -d arm-xilinx-linux-gnueabi-gdb -- -quiet'
    export arm='ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-'
    export xilinx='ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-'
    alias cgdb_fscl='cgdb -d arm-linux-gnueabihf-gdb -- -quiet'
    export fscl='ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-'
    alias cgdb_logicpd='cgdb -d arm-none-linux-gnueabi-gdb -- -quiet'
    export logicpd='ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-'
    alias cgdb_stm='cgdb -d arm-none-eabi-gdb -- -quiet'
    export stm='ARCH=arm CROSS_COMPILE=arm-none-eabi-'
    alias goarm='env CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=1 go'
}

# Lazy-load embedded dev tools on first use
cgdb-xilinx() { _embedded_dev_load; cgdb-xilinx "$@" }
cgdb_fscl() { _embedded_dev_load; cgdb_fscl "$@" }
cgdb_logicpd() { _embedded_dev_load; cgdb_logicpd "$@" }
cgdb_stm() { _embedded_dev_load; cgdb_stm "$@" }
goarm() { _embedded_dev_load; goarm "$@" }

alias vi=vim
alias vim=nvim
if (( $+commands[nvr] && $+commands[nvim] ));then
    alias nvr='nvr -s --remote'
fi

# zsh-autocomplete settings
#
zstyle ':completion:*:paths' path-completion yes
zstyle ':completion:*:processes' command 'ps -afu $USER'
zstyle ':completion:*' matcher-list 'm:{a-zäöüA-ZÄÖÜ-_}={A-ZÄÖÜa-zäöü_-} r:|=*' '+ r:|[._-]=* l:|=*'
zstyle ':completion:*' matcher-list \
    'm:{a-zäöüA-ZÄÖÜ-_}={A-ZÄÖÜa-zäöü_-} r:|=*' \
    '+ r:|[._-]=* l:|=*' \
    'l:|=* r:|=*'

zstyle ':autocomplete:*' min-input 1
# zstyle ':autocomplete:*' insert-unambiguous yes
zstyle ':autocomplete:*' add-space \
    executables aliases functions builtins reserved-words commands
# zstyle ':autocomplete:*' default-context history-incremental-search-backward

bindkey -M menuselect "^[m" accept-and-hold
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete

# Go to the root of the git repo
function u()
{
    cd ./$(git rev-parse --show-cdup)
    if  [  $#  =  1  ];  then
        cd  $1
    fi
}

# Source local settings file
LOCAL_ZSHRC=$HOME/.local.zshrc
[[ -f $LOCAL_ZSHRC ]] && source $LOCAL_ZSHRC

# }}} End configuration added by Zim install

export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # Lazy-load nvm — defer sourcing until nvm/node/npm/npx is first used
    _nvm_load() {
        unfunction nvm node npm npx 2>/dev/null
        \. "$NVM_DIR/nvm.sh"
        [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
    }
    nvm()  { _nvm_load; nvm  "$@" }
    node() { _nvm_load; node "$@" }
    npm()  { _nvm_load; npm  "$@" }
    npx()  { _nvm_load; npx  "$@" }
fi

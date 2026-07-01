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

# ^r is handled by atuin (see .zprofile) — do not restore fzf here

# Restore zsh-cycle-jobs binding — vi-mode (loaded after it) resets the viins keymap
(( $+functions[_fzf_job_chooser] )) && bindkey "${FZF_JOB_KEYBIND:-^J}" _fzf_job_chooser

# edit command in $EDITOR — standard vi `v` in normal mode
autoload -Uz edit-command-line
zle -N edit-command-line
# bindkey -M vicmd 'v' edit-command-line

# CTRL-T: use last partial word as fzf initial query, restore buffer on abort
_fzf_ctrl_t_lastword() {
    local query="" prefix="$LBUFFER" orig="$LBUFFER"

    if [[ "${LBUFFER[-1]}" != " " ]]; then
        local words=(${(z)LBUFFER})
        if (( ${#words} > 1 )); then
            local last="${words[-1]}"
            prefix="${LBUFFER[1,-(${#last}+1)]}"
            query="$last"
        fi
    fi

    local saved_opts="$FZF_CTRL_T_OPTS"
    LBUFFER="$prefix"
    FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS} --query=$query"
    fzf-file-widget
    FZF_CTRL_T_OPTS="$saved_opts"
    [[ "$LBUFFER" == "$prefix" ]] && LBUFFER="$orig"
}
zle -N _fzf_ctrl_t_lastword
(( $+functions[fzf-file-widget] )) && bindkey '^T' _fzf_ctrl_t_lastword

# -----------------
# Zsh configuration
# -----------------
# support for bash completion — loaded lazily on first use of complete/compgen
autoload bashcompinit
complete() { unfunction complete compgen; bashcompinit; complete "$@" }
compgen() { unfunction complete compgen; bashcompinit; compgen "$@" }

# Some basic settings
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$HOME/.zshistory
REPORTTIME=5
TIMEFMT='%J  %*E real  %*U user  %*S sys  %P cpu'
ZLE_RPROMPT_INDENT=0

setopt shwordsplit           # word-split $arm/$xilinx/etc env vars for `$arm make` embedded dev usage
setopt multibyte             # Support multibyte support
setopt nobgnice              # run bg jobs at full speed
setopt append_history
setopt extended_history
setopt hist_ignore_all_dups  # no duplicate
setopt hist_reduce_blanks    # trim blanks
setopt hist_verify           # show before executing history commands
setopt share_history         # share hist between sessions; implies inc_append_history
setopt bang_hist             # !keyword
setopt MULTIOS               # write to multiple files
setopt auto_remove_slash     # self explicit
setopt no_clobber            # prevent redirect from overwriting existing files (use >| to force)
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
unsetopt AUTO_NAME_DIRS

# watch=all                  # watch all logins - enabling this will print annoying msgs on terminal
logcheck=30                  # every 30 seconds
WATCHFMT="%n from %M has %a tty%l at %T %W"

autoload -U run-help
autoload run-help-git
# unalias run-help
alias help=run-help

autoload -Uz zmv
alias zmv='noglob zmv -W'
autoload -Uz zargs

# umask for new folders and files
umask 022

# reset terminal settings if previous terminal instance terminated abnormally
ttyctl -f

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
[[ $TMUX == "" ]] && (( ${+terminfo[wezterm]} )) && export TERM="wezterm"


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

# SSH agent setup — replaces zmodule ssh (which ignored 'lazy' and always ran 3× ssh-add)
# _ssh_agent_init: synchronous but 1 subprocess max when agent already running
# _ssh_load_keys: backgrounded so key-add never blocks the prompt
_ssh_agent_init() {
    local ssh_env="$HOME/.ssh-agent"
    ssh-add -l &>/dev/null
    (( $? == 2 )) || return
    [[ -r "$ssh_env" ]] && source "$ssh_env" >/dev/null
    ssh-add -l &>/dev/null
    (( $? == 2 )) || return
    (umask 066; ssh-agent >! "$ssh_env") && source "$ssh_env" >/dev/null
}
_ssh_load_keys() {
    ssh-add -l &>/dev/null && return
    typeset -a _keys=($HOME/.ssh/id_rsa*(N) $HOME/.ssh/id_ed25519*(N))
    (( ${#_keys} )) && ssh-add "${_keys[@]}" 2>/dev/null
}
_ssh_agent_init
_ssh_load_keys &!
unfunction _ssh_agent_init _ssh_load_keys

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

# Advanced History options
HIST_STAMPS="yyyy-mm-dd"
zstyle ':completion:*' keep-prefix true
zstyle ':history-append:*' preserve-days true
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_MAXLENGTH=512

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=242'


# ------------------------------
# Post-init module configuration
# ------------------------------

# zsh-autosuggestions module
#
# Disable automatic widget re-binding on each precmd (perf). Safe here: every
# module is loaded by init.zsh before the first precmd wraps widgets.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
# Fetch suggestions asynchronously so a slow `completion` lookup never blocks typing.
ZSH_AUTOSUGGEST_USE_ASYNC=true
# Suggestion sources, tried in order. match_prev_cmd is intentionally omitted: it
# needs ordered, un-deduped history and is broken by `setopt hist_ignore_all_dups`.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# Stop fetching suggestions once the line grows past N chars. Uncomment if pasting
# large blocks ever feels laggy; keep it generous so normal commands still get hints.
# ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
# Dim, italic suggestion text.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#606060,italic"

# Clear the suggestion on history-substring-search so no stale hint lingers.
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)

# Keybindings: ^Space accepts the suggestion, ^Enter accepts and runs it,
# ^o accepts one word (vi-forward-word is a default partial-accept widget).
for keymap in 'emacs' 'viins' 'vicmd'; do
    bindkey -M ${keymap} '^ '  autosuggest-accept
    bindkey -M ${keymap} '^\n' autosuggest-execute
    bindkey -M ${keymap} '^o'  vi-forward-word
done

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

# Unbind Ctrl-o for fzf-docker to get working
# bindkey -r "^o"

bindkey '^o' forward-word

# disable highlighting on paste
zle_highlight+=(paste:none)

# Keep syntax highlighting active during menu-select
_my_menu_select() {
  builtin zle .menu-select "$@"
  _zsh_highlight
}
zle -N menu-select _my_menu_select

# global alias expansion keys
# bindkey '^ ' magic-space          # control-space to bypass completion

# Customize to your needs...
# add custom users for auto completion
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

alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'

# eza settings
if (( $+commands[eza] )); then
    _eza() { LS_COLORS='' command eza --icons=always --group-directories-first "$@" }
    alias ls='_eza --git'
    alias l='_eza -1'
    alias ll='_eza -lh --git'
    alias la='_eza -lah --git'
    alias tree='_eza --tree'
fi

# zsh-autocomplete settings
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' insert-ambiguous no
zstyle ':autocomplete:*' add-space \
    executables aliases functions builtins reserved-words commands
zstyle ':autocomplete:*' default-context history-incremental-search-backward
zstyle ':autocomplete:*' min-delay 0.0
zstyle ':autocomplete:tab:*' widget-style menu-select
zstyle ':autocomplete:*' list-lines 16
zstyle ':autocomplete:*' recent-dirs cdr
zstyle ':autocomplete:*' fzf-completion no

# completions
zstyle ':completion:*' special-dirs false
zstyle ':completion:*:paths' path-completion yes
zstyle ':completion:*:directories' sort no
if [[ ${ZONFIG_OS:-linux} == linux ]]; then
    zstyle ':completion:*:processes' command 'ps -u $USER -o pid,user,%cpu,tty,cputime,cmd'
    zstyle ':completion:*:*:kill:*' command 'ps -u $USER -o pid,user,%cpu,tty,cputime,cmd'
    zstyle ':completion:*:processes-names' command 'ps -u $USER -o comm='
else
    zstyle ':completion:*:processes' command 'ps aux -u $USER'
    zstyle ':completion:*:*:kill:*' command 'ps aux -u $USER'
    zstyle ':completion:*:processes-names' command 'ps xco command -u $USER'
fi
# Progressive "fuzzy" matching for every completion, git refs included
# (e.g. `git checkout <substring><TAB>` matches a branch name anywhere in it,
#  `git switch`, `git merge`, `git rebase`, tags, remotes, etc.).
# zsh tries each level in order and stops at the first that yields matches:
#   0  ''                          exact
#   1  m:{a-zA-Z}={A-Za-z}         case-insensitive
#   2  + r:|[._-]=* r:|=*          complete across [._-]/digit word boundaries
#   3  l:|=* r:|=*                 substring match anywhere in the candidate
# Typo tolerance comes from the _approximate completer (set in the
# zimfw-customization/completion module).
zstyle ':completion:*' matcher-list \
    '' \
    'm:{a-zA-Z}={A-Za-z}' \
    'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'

# Advanced completion options
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:| |=*' '+l:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' original true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' group-order files directories aliases functions commands

# Ignore case in completion
zstyle ':completion:*' case-insensitive true

# Enable matcher-continue for progressive matching
zstyle ':completion:*:match:*' original only

# Menu selection with arrow keys
zstyle ':completion:*:history-words' menu yes

# Use LS_COLORS for completion menu colors
typeset -a list_colors
for c in ${(s/:/)LS_COLORS}; do
  list_colors+="${c%%=*}"*="${c#*=}"
done
zstyle ':completion:*' list-colors $list_colors
zstyle ':completion:*:directories' list-colors $list_colors

bindkey -M menuselect "^[m" accept-and-hold
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete

# Clear to end of display before completion list renders
_comppre_clear() { echoti ed 2>/dev/null }
compprefuncs+=(_comppre_clear)

# Go to the root of the git repo
function u() {
    local cdup
    cdup=$(git rev-parse --show-cdup 2>/dev/null) || return 1
    cd ./${cdup}
    [[ $# == 1 ]] && cd $1
}

# Copy file with a progress bar
function cpp() {
    if [[ -x "$(command -v rsync)" ]]; then
        # rsync -avh --progress "${1}" "${2}"
        rsync -ah --info=progress2 "${1}" "${2}"
    else
        set -e
        strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
            | awk '{
                count += $NF
                if (count % 10 == 0) {
                    percent = count / total_size * 100
                    printf "%3d%% [", percent
                    for (i=0;i<=percent;i++)
                        printf "="
                        printf ">"
                    for (i=percent;i<100;i++)
                        printf " "
                        printf "]\r"
                }
            }
    END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
                fi
}

# mkdir -p then cd into it
mkcd() { mkdir -p "$@" && cd "${@[-1]}" }

# cd up N levels (default 1): up 3 → cd ../../..
up() {
    local d='' limit="${1:-1}"
    for ((i=1; i<=limit; i++)); do d="../$d"; done
    cd "${d:-.}" || return
}

export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # Lazy-load nvm — defer sourcing until nvm/node/npm/npx is first used
    _nvm_load() {
        unfunction nvm node npm npx 2>/dev/null
        \. "$NVM_DIR/nvm.sh"
    }
    nvm()  { _nvm_load; nvm  "$@" }
    node() { _nvm_load; node "$@" }
    npm()  { _nvm_load; npm  "$@" }
    npx()  { _nvm_load; npx  "$@" }
fi

# Source local settings file
LOCAL_ZSHRC=$HOME/.local.zshrc
[[ -f $LOCAL_ZSHRC ]] && source $LOCAL_ZSHRC

# }}} End configuration added by Zim install

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

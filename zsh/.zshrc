# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#
#
# ------------------
# Initialize modules
# ------------------

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

# -----------------
# Zsh configuration
# -----------------
# support for bash completion

autoload bashcompinit
bashcompinit

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
setopt no_auto_remove_slash  # do not remove slash on directory completion
setopt append_history        # append
setopt hist_ignore_all_dups  # no duplicate
setopt hist_reduce_blanks    # trim blanks
setopt hist_verify           # show before executing history commands
setopt inc_append_history    # add commands as they are typed, dont wait until shell exit
setopt share_history         # share hist between sessions
setopt bang_hist             # !keyword
setopt MULTIOS               # write to multiple files
setopt auto_remove_slash     # self explicit
setopt clobber               # clobber on redirect
setopt interactive_comments  # enable interactive comments
setopt aliases               # enable aliases
setopt auto_cd               # if command is a path, cd into it
setopt auto_remove_slash     # self explicit
setopt chase_links           # resolve symlinks
setopt correct               # try to correct spelling of commands
setopt extended_glob         # activate complex pattern globbing
setopt glob_dots             # include dotfiles in globbing
setopt nohashdirs            # avoid having to run `rehash` on each new executable in $PATH
setopt autopushd
setopt completealiases
setopt pushdignoredups
setopt pushdminus
setopt alias_func_def       # allow alias with function names
setopt interactivecomments  # allows you to type Bash style comments on your command line

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

# If this is removed, cursor after prompt behave weirdly
[[ $TMUX = "" ]] && export TERM="wezterm"


#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

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

# SSH key management
zstyle ':zim:ssh' ids 'id_rsa1' 'id_rsa2' 'id_rsa3'

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
if [[ ${keymap} = 'vicmd' ]];then
    bindkey -M ${keymap} "j" history-substring-search-down
    bindkey -M ${keymap} "k" history-substring-search-up
fi # if


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
ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)
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

# disable highlighting on paste
zle_highlight+=(paste:none)

# global alias expansion keys
# bindkey '^ ' magic-space          # control-space to bypass completion

# Initialize fzf - https://github.com/junegunn/fzf
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# Don't use fzf completions
if (( $+commands[fzf] )); then
    fzf_default_completion='expand-or-complete-with-indicator'
fi

# Customize to your needs...
# add custom users for auto completion
users=($USER rreddy "$users")
zstyle ':completion:*' users $users

# xilinx devel setup
alias cgdb-xilinx='cgdb -d arm-xilinx-linux-gnueabi-gdb -- -quiet'
export arm='ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-'
export xilinx='ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-'

# freescale devel settings
alias cgdb_fscl='cgdb -d arm-linux-gnueabihf-gdb -- -quiet'
export fscl='ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-'

# freescale devel settings
alias cgdb_logicpd='cgdb -d arm-none-linux-gnueabi-gdb -- -quiet'
export logicpd='ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-'

# STM devel settings
alias cgdb_stm='cgdb -d arm-none-eabi-gdb -- -quiet'
export stm='ARCH=arm CROSS_COMPILE=arm-none-eabi-'

alias goarm='env CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=1 go'

export GEM_HOME=$HOME/gems

path=(
    /usr/lib/llvm-3.6/bin	# for clang
    /opt/SEGGER/JLink
    $HOME/gems/bin
    $HOME/go/bin
	$HOME/.local/bin/
    $path[@]
)

GOPATH=$HOME/go
PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

# colorize output of few utilities
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

alias vi=vim
alias vim=nvim

# Source local settings file
LOCAL_ZSHRC=$HOME/.local.zshrc
[[ -f $LOCAL_ZSHRC ]] && source $LOCAL_ZSHRC

# turn off ZLE bracketed paste in dumb term
# otherwise turn on ZLE bracketed-paste-magic
if [[ $TERM == dumb ]]; then
    unset zle_bracketed_paste
else
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
fi

# TODO: move this another file
# source $HOME/.custom/completions.zsh
# source $HOME/.custom/utils.zsh
# source $HOME/.custom/ratheesh.zsh-theme

# }}} End configuration added by Zim install


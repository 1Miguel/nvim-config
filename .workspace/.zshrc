# Enable Powerlevel10k instant prompt.
# Keep this near the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  sudo
  z
  docker
  docker-compose
)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─────────────────────────────────────────────
# Environment
# ─────────────────────────────────────────────

export EDITOR="nvim"
export VISUAL="nvim"

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
# UVM core
# export UVM_HOME="$HOME/dev/uvm-core"
export UVM_HOME="$HOME/dev/uvm-verilator-1800.2-2020.3.1/src/"

# ─────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c='clear'
alias cls='clear'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# ─────────────────────────────────────────────
# Useful options
# ─────────────────────────────────────────────

setopt AUTO_CD
setopt CORRECT
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# ─────────────────────────────────────────────
# Completion
# ─────────────────────────────────────────────

autoload -Uz compinit
compinit

# ─────────────────────────────────────────────
# Syntax highlighting / autosuggestions
# ─────────────────────────────────────────────

# Uncomment these if installed manually.
# source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─────────────────────────────────────────────
# FZF
# ─────────────────────────────────────────────

if command -v fzf >/dev/null 2>&1; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# ─────────────────────────────────────────────
# NVM
# ─────────────────────────────────────────────

export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi

if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi


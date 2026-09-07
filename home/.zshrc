# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnosterzak"

plugins=( 
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
# pokemon-colorscripts --no-title -s -r #without fastfetch
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-vini.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# My own configs
alias nv='neovide --fork'
alias nvie='neovide'
alias nvmc='kitty @ launch --override font_family=Monocraft nvim'

export PATH=$PATH:/opt/intelFPGA_lite/20.1/quartus/bin:/opt/intelFPGA_lite/20.1/modelsim_ase/bin


export QSYS_ROOTDIR="/home/vinicius/intelFPGA_lite/23.1std/quartus/sopc_builder/bin"

# Load Node.js, NVM and Angular only when one of their commands is first used.
# This keeps new Kitty windows responsive without removing those tools.
export NVM_DIR="$HOME/.nvm"
load_node_tools() {
    unfunction node npm npx nvm ng yarn pnpm corepack 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

    if command -v ng >/dev/null 2>&1; then
        source <(ng completion script)
    fi
}

node() { load_node_tools; command node "$@"; }
npm() { load_node_tools; command npm "$@"; }
npx() { load_node_tools; command npx "$@"; }
nvm() { load_node_tools; nvm "$@"; }
ng() { load_node_tools; command ng "$@"; }
yarn() { load_node_tools; command yarn "$@"; }
pnpm() { load_node_tools; command pnpm "$@"; }
corepack() { load_node_tools; command corepack "$@"; }

fpath+=${ZDOTDIR:-~}/.zsh_functions

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
load_bun_completion() {
    unfunction bun bunx 2>/dev/null
    [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
}

bun() { load_bun_completion; command bun "$@"; }
bunx() { load_bun_completion; command bunx "$@"; }

# opencode
export PATH=/home/vinicius/.opencode/bin:$PATH

# Created by `pipx` on 2026-04-09 18:05:45
export PATH="$PATH:/home/vinicius/.local/bin"

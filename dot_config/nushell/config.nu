use std/util "path add"

# startup
fastfetch

if ($env.TERM_PROGRAM? | default "") != "Apple_Terminal" {
    $env.PROMPT_COMMAND = { ||
        oh-my-posh prompt print primary --config ~/.config/ohmyposh/zen.toml
    }
}

# editor
$env.EDITOR = "nvim"
$env.VISUAL = $env.EDITOR
$env.config.buffer_editor = "nvim"

# basic shell behavior
$env.config = (
  $env.config
  | upsert show_banner false
  | upsert edit_mode emacs
  | upsert history.max_size 5000
)

# paths
path add "/opt/homebrew/bin"
path add "/opt/homebrew/sbin"
path add $"($env.HOME)/.local/opt/go/bin"
path add $"($env.HOME)/go/bin"
path add "/Users/david/.spicetify"
path add $"($env.HOME)/.opencode/bin"

# aliases
alias v = nvim
alias vdiff = nvim -d
# alias ls = eza --icons=always
# alias lst = eza -lah -snew
alias tree = eza --tree
alias c = clear
alias top = btop
alias zshrc = nvim $nu.config-path
alias normal = ~/util/toggle_sleep/toggle_sleep.sh normal normal normal
alias never = ~/util/toggle_sleep/toggle_sleep.sh never never never
alias vghostty = nvim ~/.config/ghostty/config

# tmux
alias ta = tmux attach -t
alias tn = tmux new-session -d -s
alias tk = tmux kill-session -t
alias tl = tmux list-sessions
alias td = tmux detach
alias tch = bash -lc 'clear; tmux clear-history; clear'

# fzf helper that replaces your fzfe alias
def fzfe [] {
  let selected = (
    ^fzf -m --preview 'bat --color=always {}'
    | decode utf-8
    | lines
  )

  if ($selected | length) > 0 {
    ^nvim ...$selected
  }
}

# make dir and cd into it
def --env mkcd [dir: string] {
  mkdir $dir
  cd $dir
}

# copy file://$PWD/index.html to clipboard
def cpindex [] {
  $"file://($env.PWD)/index.html" | ^pbcopy
}

# compile typst then copy current dir
def tpcomp [] {
  ^typst compile davidResume.typ
  $env.PWD | ^pbcopy
}

# list files whenever directory changes
$env.config = (
  $env.config
  | upsert hooks.env_change.PWD (
      ($env.config.hooks.env_change.PWD? | default [])
      | append { |_, _| ls }
    )
)

# keybindings similar to your zsh setup
$env.config.keybindings = (
  $env.config.keybindings
  | append [
      {
        name: history_up_ctrl_p
        modifier: control
        keycode: char_p
        mode: [emacs vi_insert]
        event: { send: up }
      }
      {
        name: history_down_ctrl_n
        modifier: control
        keycode: char_n
        mode: [emacs vi_insert]
        event: { send: down }
      }
      {
        name: kill_to_start_alt_w
        modifier: alt
        keycode: char_w
        mode: [emacs vi_insert]
        event: { edit: cutfromlinestart }
      }
      {
        name: fuzzy_cd_ctrl_y
        modifier: control
        keycode: char_y
        mode: [emacs vi_insert]
        event: {
          send: executehostcommand
          cmd: "cd (ls | where type == dir | get name | str join (char nl) | fzf | decode utf-8 | str trim)"
        }
      }
    ]
)

# zoxide
# one-time:
#   zoxide init nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu

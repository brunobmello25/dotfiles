export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig:$PKG_CONFIG_PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/bruno.mello/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/bruno.mello/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/bruno.mello/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/bruno.mello/google-cloud-sdk/completion.zsh.inc'; fi

export PATH=/opt/homebrew/opt/libpq/bin:$PATH

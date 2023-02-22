print_step_header "Installing asdf plugins"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
wait_for_keypress

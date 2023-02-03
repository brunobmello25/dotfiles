#!/usr/bin/env bash



# make a function that waits for using to press any key
function wait_for_keypress {
    echo "Press any key to continue"
    read -n 1 -s
    echo ""
}


echo "Updating and upgrading system"
sudo apt update -y && sudo apt upgrade -y

wait_for_keypress

echo "Installing packages"
to_install=(fzf git curl wget flameshot docker-compose postgresql-client ranger tmux zsh stow ripgrep bat fd-find alacritty)
for i in "${to_install[@]}"; do
    sudo apt install -y $i
done

wait_for_keypress

if ! command -v neovim &> /dev/null
then
  echo "Installing neovim"
  sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt update
fi

wait_for_keypress

echo "Installing oh-my-zsh"
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh # TODO: make this idempotent

[ ! -d "${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search" ] && \
          git clone https://github.com/joshskidmore/zsh-fzf-history-search \
          ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search

wait_for_keypress

[ ! -d "$HOME/.ssh" ] && echo "Setting up ssh keys" && ssh-keygen -t ed25519 -C "bruno.barros.mello@gmail.com" && wait_for_keypress

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

wait_for_keypress

echo "Installing google cloud cli"
sudo apt install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg
sudo apt update && sudo apt install google-cloud-cli

wait_for_keypress

if [! -d "$HOME/.asdf" ]; then
  echo "Installing asdf"]
  ASDF_VERSION=$(curl -s "https://api.github.com/repos/asdf-vm/asdf/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v$ASDF_VERSION

  wait_for_keypress
fi


# if [ ! -d "$HOME/.dotfiles" ]; then 
#   echo "Cloning dotfiles"
#   git clone https://github.com/brunobmello25/dotfiles.git ~/.dotfiles
# fi





echo "stowing dotfiles"
cd ~/.dotfiles
stow git
stow fd
stow tmux
stow zsh
stow alacritty
stow ignore


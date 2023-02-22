#!/usr/bin/env bash

# force exit on error
set -e

function wait_for_keypress {
    echo ""
    echo "press any key to continue"

    read -n 1 -s

    echo ""
}

function print_step_header {
    echo ""
    echo "=============================="
    echo " $1 "
    echo "=============================="
    echo ""
}

mkdir -p ~/dev

print_step_header "Updating and upgrading system"
sudo apt update -y && sudo apt dist-upgrade -y
wait_for_keypress

print_step_header "Installing packages"
sudo apt install -y fzf git curl wget flameshot postgresql-client ranger tmux zsh stow ripgrep bat fd-find alacritty
wait_for_keypress

print_step_header "Installing vanilla gnome session"
sudo apt install -y gnome-session
wait_for_keypress

if ! command -v neovim &> /dev/null
then
  print_step_header "Installing neovim"
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt update -y
  sudo apt install -y neovim
  wait_for_keypress
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  print_step_header "Installing oh-my-zsh"
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  wait_for_keypress
fi

if [ ! -d "${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search"  ]; then
  print_step_header "Installing zsh-fzf-history-search"

  git clone https://github.com/joshskidmore/zsh-fzf-history-search \
  ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search

  wait_for_keypress
fi

if [ ! -d "$HOME/.ssh" ]; then
 print_step_header "Setting up ssh keys"
 ssh-keygen -t ed25519 -C "bruno.barros.mello@gmail.com"
 wait_for_keypress
fi

print_step_header "Installing lazygit"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
wait_for_keypress

# TODO: fix this
# print_step_header "Installing docker"
# sudo apt-get update
# sudo apt-get install \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release
# sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update -y
# sudo apt-get install --reinstall docker-ce docker-ce-cli containerd.io docker-compose-plugin
# sudo groupadd docker
# sudo usermod -aG docker $USER
# wait_for_keypress

print_step_header "Installing google cloud cli"
sudo apt install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg
sudo apt update -y && sudo apt install google-cloud-cli
wait_for_keypress

if [ ! -d "$HOME/.asdf" ]; then
  print_step_header "Installing asdf"
  ASDF_VERSION=$(curl -s "https://api.github.com/repos/asdf-vm/asdf/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v$ASDF_VERSION

  wait_for_keypress
fi

if [ ! -d "$HOME/dev/skeleton.nvim" ]; then
  SKELETON_NVIM_PATH=~/dev/skeleton.nvim
  print_step_header "Installing skeleton.nvim"
  git clone https://github.com/brunobmello25/skeleton.nvim.git $SKELETON_NVIM_PATH
  cd $SKELETON_NVIM_PATH
  chmod +x ./install.sh
  ./install.sh
  cd
  wait_for_keypress
fi


print_step_header "stowing dotfiles"
cd ~/.dotfiles
stow git
stow fd
stow tmux
stow zsh
stow alacritty
stow ignore
cd
wait_for_keypress

print_step_header "changing default shell to zsh"
chsh -s $(which zsh)
wait_for_keypress

print_step_header "Install ranger devicons"
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
wait_for_keypress

print_step_header "Adjusting keyboard layout"
sudo apt-add-repository -y ppa:rael-gc/utils
sudo apt update
sudo apt install win-us-intl
gsettings set org.gnome.settings-daemon.plugins.xsettings disabled-gtk-modules '["'keyboard'"]'
im-config -n uim
wait_for_keypress

echo "Done!"
echo "Now remember to add your ssh key to github and then run the after script"

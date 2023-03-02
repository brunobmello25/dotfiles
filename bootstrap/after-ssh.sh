echo "Adjusting git remotes to use SSH instead of HTTPS..."

cd ~/dev/skeleton.nvim
git remote remove origin
git remote add origin git@github.com:brunobmello25/skeleton.nvim.git

cd ~/.dotfiles
git remote remove origin
git remote add origin git@github.com:brunobmello25/dotfiles.git

echo "Done!"

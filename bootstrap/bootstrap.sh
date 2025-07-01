#!/bin/bash

set -euo pipefail

function setup_fzf() {
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

	if [[ -d ~/.fzf ]]; then
		~/.fzf/install --all --no-bash --no-fish --no-zsh
		echo "fzf installed successfully."
	else
		echo "Failed to clone fzf repository."
		exit 1
	fi
}


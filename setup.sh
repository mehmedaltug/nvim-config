#!/bin/bash

if command -v apt &> /dev/null; then
    # Install required packages
    sudo apt update
    sudo apt install -y nodejs npm gcc python3 pipx curl default-jdk
    sudo npm i -g tree-sitter-cli @google/gemini-cli
    pipx install uv

    # Install Neovim-Latest
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz
    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
fi

if command -v pacman &> /dev/null; then
    sudo pacman -Syu nodejs npm gcc python3 python-pipx jdk-openjdk tree-sitter-cli neovim
    sudo npm i -g @google/gemini-cli
    pipx install uv
fi


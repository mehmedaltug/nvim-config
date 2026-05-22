#!/bin/bash


if command -v apt &> /dev/null; then
    # Install required packages
    sudo apt update
    sudo apt install -y nodejs npm gcc python3 pipx fzf curl default-jdk
    sudo npm i -g tree-sitter-cli @google/gemini-cli
    pipx install uv

    # Install Neovim-Latest
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz
    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc

    # -- Obsolete with Mason --
    # Install JDTLS
    # curl -LO https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.57.0/jdt-language-server-1.57.0-202602261110.tar.gz
    # mv download.php jdtls.tar.gz
    # mkdir ~/jdtls
    # tar xf jdtls.tar.gz -C ~/jdtls
    # rm jdtls.tar.gz
    # export PATH="$PATH:~/jdtls/bin"
    # echo 'export PATH="$PATH:~/jdtls/bin"' >> ~/.bashrc
fi

if command -v pacman &> /dev/null; then
    sudo pacman -Syu nodejs npm gcc python3 python-pipx fzf jdk-openjdk tree-sitter-cli neovim
    sudo npm i -g @google/gemini-cli
    pipx install uv
fi


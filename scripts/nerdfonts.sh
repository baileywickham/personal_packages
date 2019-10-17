# Incosada regualr
if [ -d "~/.nerdfonts" ]; then
    echo "nerdfonts directory already exists"
else
    git clone https://github.com/ryanoasis/nerd-fonts.git ~/.nerdfonts
    ~/.nerdfonts/install.sh
fi

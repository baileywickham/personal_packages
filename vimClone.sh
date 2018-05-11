cloneVimrc() {
    if [ ! -f "~/.vimrc" ]
    then
        touch ~/.vimrc
    fi
    ln -s $PWD/vimrc ~/.vimrc
    cp -r $PWD/vim/ ~/.vim/
cloneVimrc()

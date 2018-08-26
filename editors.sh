cloneVimrc() {
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    rm ~/.vimrc
    ln -s $PWD/vimrc ~/.vimrc
}
cloneTmuxConf () {
    ln -s $PWD/tmux.conf ~/.tmux.conf
    ln -s $PWD/tmux.conf.local ~/.tmux.conf.local 
}
cloneVimrc
cloneTmuxConf

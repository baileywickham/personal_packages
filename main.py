import shutil, argparse, os, subprocess
from pathlib import Path
from sys import argv, exit

import appends
remote = False
home = Path.home()

def copyFile(*, file, path):
    path = Path(path)
    file = Path(file)
    shutil.copy2(file,path)

def linkFile(file): 
    subprocess.Popen(['ln',os.getcwd()+f'/{file}',str(Path.home())+f'/{file}'])


def main():
    vim()
    bash()
    tmux() 
    #ssh()
    linkFile('.gitignore_global')
    #do git
    #git config --global core.excludefile ~/.gitignore_global
    if remote:
        pass
        #copyFile(Path('70-utf.rules'),Path('/etc/udev/rules.d'/))
        #copyFile(Path('google-chrome.list',Path('/etc/apt/sources.list.d/google-chrome.list'))
    

def vim():
    if (home / Path('.vimrc')).exists():
        os.remove(home / Path('.vimrc'))
    linkFile('.vimrc')
    subprocess.Popen(['git','clone','https://github.com/VundleVim/Vundle.vim.git', '~/.vim/bundle/Vundle.vim'])
     #subprocess.Popen(['vim', '-c', 'PluginInstall'])


def bash():
    if (home / Path('.bashrc')).exists():
        os.remove(home / Path('.bashrc'))
    linkFile('.bashrc')


def tmux():
    if (home / Path('.vimrc')).exists() and (home / Path('.tmux.conf.local')).exists():
        os.remove(home / Path('.tmux.conf'))
        os.remove(home / Path('.tmux.conf.local'))
    linkFile('.tmux.conf')
    linkFile('.tmux.conf.local')

def ssh():
    if not Path(home / '.ssh/config').exists():
        os.mkdir(Path(home / '.ssh'))
        linkFile('config')

if __name__ == '__main__':
    main()


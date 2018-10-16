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

def linkFile(*, file, path): 
    os.link(file, path)


def main():
    vim()
    bash()
    tmux() 
    ssh()
    if remote:
        pass
        #copyFile(Path('70-utf.rules'),Path('/etc/udev/rules.d'/))
        #copyFile(Path('google-chrome.list',Path('/etc/apt/sources.list.d/google-chrome.list'))
    

def vim():
    if (home / Path('.vimrc')).exists():
        os.remove(home / Path('.vimrc'))
    linkFile(file='.vimrc', path=home)
    subprocess.Popen(['git','clone','https://github.com/VundleVim/Vundle.vim.git', '~/.vim/bundle/Vundle.vim'])
    #subprocess.Popen(['vim', '-c', 'PluginInstall'])


def bash():
    if (home / Path('.bashrc')).exists():
        os.remove(home / Path('.bashrc'))
    linkFile(file='.bashrc',path=home)


def tmux():
    if (home / Path('.vimrc')).exists() and (home / Path('.tmux.conf.local')).exists():
        os.remove(home / Path('.tmux.conf'))
        os.remove(home / Path('.tmux.conf.local'))
    linkFile(file='.tmux.conf',path=home)
    linkFile(file='.tmux.conf.local',path=home)

def ssh():
    if not Path(home / '.ssh/config').exists():
        os.mkdir(Path(home / '.ssh'))
        linkFile(file='config',path=Path(home / '.ssh/'))

if __name__ == '__main__':
    main()


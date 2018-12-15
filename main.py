import shutil, argparse, os, subprocess
from pathlib import Path
from sys import argv, exit

import appends
remote = False
home = str(Path.home())

def copyFile(*, file, path):
    path = Path(path)
    file = Path(file)
    shutil.copy2(file,path)

def linkFile(file, loc=home): 
    subprocess.Popen(['ln','-sf',os.getcwd()+f'/{file}',loc+f'/{file}'])


def main():
    nvim()
    #bash()
    tmux() 
    #ssh()
    linkFile('.gitignore_global')
    #do git
    #git config --global core.excludefile ~/.gitignore_global
    if remote:
        pass
        #copyFile(Path('70-utf.rules'),Path('/etc/udev/rules.d'/))
        #copyFile(Path('google-chrome.list',Path('/etc/apt/sources.list.d/google-chrome.list'))
    
def nvim():
    pass
   
def tmux():
    if (home / Path('.vimrc')).exists() and (home / Path('.tmux.conf.local')).exists():
        os.remove(home / Path('.tmux.conf'))
        os.remove(home / Path('.tmux.conf.local'))
    linkFile('.tmux.conf')
    linkFile('.tmux.conf.local')

def vim():
    linkFile('.vimrc')
    #subprocess.Popen(['git','clone','https://github.com/VundleVim/Vundle.vim.git', '~/.vim/bundle/Vundle.vim'])
    #subprocess.Popen(['vim', '-c', 'PluginInstall'])

def bash():
    linkFile('.bashrc')



def ssh():
    if not Path(home / '.ssh/config').exists():
        os.mkdir(Path(home / '.ssh'))
        linkFile('config')

if __name__ == '__main__':
    main()


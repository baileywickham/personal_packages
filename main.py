import shutil, argparse, os, subprocess
from pathlib import Path
from sys import argv, exit

import appends
remote = False
home = Path.home()

def moveFile(*, file, path):
    path = Path(path)
    file = Path(file)


def linkFile(*, file, path): 
    os.link(file, path)


def main():
    #subprocess.Popen(['vim', '-c', 'PluginInstall'])
    #vim()
    # bash()
    tmux() 


def vim():
    linkFile(file='.vimrc', path=home)
    if remote:
        subprocess.Popen(['vim', '-c', 'PluginInstall'])


def bash():
    linkFile(file='.bashrc',path=home)


def tmux():
    linkFile(file='.tmux.conf',path=home)
    linkFile(file='.tmux.conf.local',path=home)


if __name__ == '__main__':
    main()


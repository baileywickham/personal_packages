import shutil, argparse, os, subprocess
from pathlib import Path
from sys import argv, exit

import appends

home = Path.home()

def moveFile(*, file, path):
    path = Path(path)
    file = Path(file)


def linkFile(*, file, path): 
    os.link(file, path)


def main():
    #subprocess.Popen(['vim', '-c', 'PluginInstall'])


if __name__ == '__main__':
    remote = argv if '--remote' in argv[1] or '--local' in argv[1] else exit(appends.exit)
    main()


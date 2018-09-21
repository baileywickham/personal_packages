import shutil
import argparse
from pathlib import Path
from sys import argv, exit

import appends

home = Path.home()

def moveFile(*, file, path):
    path = Path(path)
    file = Path(file)
 

def main():
    pass


if __name__ == '__main__':
    remote = argv if '--remote' in argv[1] or '--local' in argv[1] else exit(appends.exit)
    main()


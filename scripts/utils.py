import os
import shlex
import subprocess
import functools


def runIn(directory):
    def dec(func):
        @functools.wraps(func)
        def wrapper_repeat(*args, **kwargs):
            value = func(*args, **kwargs)
            return value
        return wrapper_repeat
    return dec

def do(thing, cwd=None):
    thing = thing.strip()
    out, error = '', ''
    for line in thing.split('\n'):
        if line == '':
            continue
        cmds = shlex.split(line)
        p = subprocess.Popen(cmds, cwd=cwd,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        o, e = p.communicate()
        out += str(o)
        error += str(e)

    return out, error

@runIn('/home/y/')
def test():
    print(do('''ls -lah
    echo 'hi' '''))

test()

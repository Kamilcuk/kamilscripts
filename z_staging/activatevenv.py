#!/usr/bin/env python3

import os
import sys
import subprocess


def findfile(startdir, pattern):
    for root, dirs, files in os.walk(startdir):
        for name in files:
            if name.find(pattern) >= 0:
                return root + os.sep + name
    return None


def install_activate_venv(root=os.path.dirname(os.path.realpath(__file__)), venvname='_venv', silent=False, pip=True):
    # https://stackoverflow.com/questions/46056557/python-script-to-activate-and-keep-open-a-virtualenv
    if sys.prefix != sys.base_prefix:
        print('Already in virtual environment.')
    else:
        def find_activate():
            return findfile(os.path.join(venv_path, 'bin'), 'activate')
        venv_path = os.path.join(root, venvname)
        activate = find_activate()
        if activate is None:
            if not silent:
                print('Creating and activating virtual environment in ' + venv_path)
            import venv
            env = venv.EnvBuilder(with_pip=True)
            env.create(venv_path)
            activate = find_activate()
        else:
            if not silent:
                print('Activating virtual environment in ' + venv_path)
        os.environ['PATH'] = os.path.dirname(activate) + os.pathsep + os.environ['PATH']
        sys.path.insert(1, os.path.dirname(findfile(venv_path, 'easy_install.py')))
    if pip:
        subprocess.run(['pip', 'install', '--disable-pip-version-check', '-qr',
                       os.path.join(root, 'requirements.txt')], check=True)




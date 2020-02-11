#!/usr/bin/env python3

import argparse
import os
import sys
from pathlib import Path

SHORT_PY_VERSION = str(sys.version_info[0]) + str(sys.version_info[1])


def touchCache(path: str) -> bool:
    """
    On Windows, when installing into a writable folder (not 'Program Files'),
    python and qml generate cache files next to the source files.
    On uninstall, those should be gone.
    In order to do that seamlessly, the installer/uninstaller needs to know about these files beforehand.
    The solution taken here is to generate 0-byte versions of those files, just before the packaging runs.

    :param path: Top level folder
    :return: Success (True) or exception (False).
    """
    if path.endswith("/") or path.endswith("\\") or path.endswith("\""):
        path = path[0:-1]
    create_files = []  # List[str]

    try:
        for root, _, filenames in os.walk(path):
            for filename in filenames:

                if filename.endswith(".py"):
                    pyc_filename = filename[0:-3] + ".cpython-" + SHORT_PY_VERSION + ".pyc"
                    create_files.append(os.path.join(root, "__pycache__", pyc_filename))

                if filename.endswith(".qml"):
                    qmlc_filename = filename + "c"
                    create_files.append(os.path.join(root, qmlc_filename))

    except IOError as ex:
        print("Could not read folder (recursively) {} because {}".format(path, str(ex)))
        return False

    try:
        for filename in create_files:
            dirname = os.path.dirname(filename)
            if not os.path.exists(dirname):
                os.makedirs(dirname)
            Path(filename).touch()

    except IOError as ex:
        print("Could not write to folder {} because {}".format(path, str(ex)))
        return False

    return True


def mainfunc():
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--folder", type = str, default = "")
    args = parser.parse_args()
    touchCache(args.folder)


if __name__ == "__main__":
    sys.exit(mainfunc())

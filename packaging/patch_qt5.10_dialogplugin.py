#!/usr/bin/env python3
#
# CURA-6074
# QTBUG-57832: https://bugreports.qt.io/browse/QTBUG-57832?focusedCommentId=456400&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-456400
#
import argparse
import os
import sys


QT_DIALOG_PLUGIN_FILENAME = "dialogplugin.dll"


#
# Recursively looks for "dialogplugin.dll" in the given install_dir directory and returns the full path to it if it is
# found. Returns an empty string if the file is not found.
#
def find_dialogplugin_dll(install_dir: str) -> str:
    filepath = ""
    for root, dirnames, filenames in os.walk(install_dir):
        if QT_DIALOG_PLUGIN_FILENAME in filenames:
            filepath = os.path.join(root, QT_DIALOG_PLUGIN_FILENAME)
            break
    return filepath


#
# CURA-6074
# QTBUG-57832: https://bugreports.qt.io/browse/QTBUG-57832?focusedCommentId=456400&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-456400
#
# Patches the "dialogplugin.dll" file that's bundled with PyQt5 5.10 to skip adding all available system drives to
# the shortcuts. This function changes a conditional jump command for adding the drives to a non-conditional jump, so
# the code for adding the drives is skipped.
#
def patch_dialogplugin_dll_qt5_10(filepath: str) -> None:
    location = 0x1B38  # Need to change this byte from "74" JE to "EB" JMP
    new_byte = b'\xEB'
    try:
        with open(filepath, "rb") as f:
            content = f.read()

        # Validate that we have the correct file first. We are replacing "74 77" with "EB 77"
        part_content = content[location:location + 2]
        expected_content = b"\x74\x77"
        if part_content != expected_content:
            raise RuntimeError("Expecting '%s' at location %s but got '%s' instead" %
                               (expected_content.hex(), hex(location), part_content.hex()))

        # Replace with new content
        new_content = b"".join([content[:location], new_byte, content[location + 1:]])
        with open(filepath, "wb") as f:
            f.write(new_content)
    except Exception as e:
        raise RuntimeError("Failed to modify '%s': %s" % (filepath, e))

    print("File '%s' patched." % filepath)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("install_dir", action="store", type = str, nargs = 1)
    args = parser.parse_args()

    # Find the file
    install_dir = args.install_dir[0]
    dialogplugin_filepath = find_dialogplugin_dll(install_dir)
    if not dialogplugin_filepath:
        print("Cannot find '%s' in directory '%s'" % (QT_DIALOG_PLUGIN_FILENAME, install_dir))
        sys.exit(1)

    # Patch the file
    patch_dialogplugin_dll_qt5_10(dialogplugin_filepath)


if __name__ == "__main__":
    main()

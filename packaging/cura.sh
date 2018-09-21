#!/bin/sh

scriptdir=$(dirname $0)

export PYTHONPATH=$scriptdir/lib/python3.5
export QT_PLUGIN_PATH=$scriptdir/qt/plugins
export QML2_IMPORT_PATH=$scriptdir/qt/qml
export QT_QPA_FONTDIR=/usr/share/fonts
export QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb

cura "$@"

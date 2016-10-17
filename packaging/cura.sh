#!/bin/sh

scriptdir=$(dirname $0)

export QT_PLUGIN_PATH=$scriptdir/qt/plugins
export QML2_IMPORT_PATH=$scriptdir/qt/qml
export QT_QPA_FONTDIR=$scriptdir/qt/fonts

cura $@

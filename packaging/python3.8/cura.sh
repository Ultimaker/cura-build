#!/bin/bash

scriptdir="$(dirname $0)"

export PYTHONPATH=$scriptdir/../lib
#export QT_PLUGIN_PATH=$scriptdir/qt/plugins
export QML2_IMPORT_PATH=$scriptdir/../lib/UM/Qt/qml
#export QT_QPA_FONTDIR=/usr/share/fonts
#export QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb

# Use the openssl.cnf packaged in the AppImage
#export OPENSSL_CONF=$scriptdir/openssl.cnf

"$scriptdir/../cura" "$@"

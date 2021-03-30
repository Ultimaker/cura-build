#!/bin/bash

# Sign the libraries of the application
echo "===================================="
echo "Signing the libraries of Cura . . ."
echo "===================================="
find ./Ultimaker\ Cura.app -name "*.dylib" -exec codesign --verbose --force --sign $codesign_identity {} \;
find ./Ultimaker\ Cura.app -name "*.so" -exec codesign --entitlements ../../signing/cura.entitlements --verbose --force -o runtime --sign $codesign_identity {} \;

# Sign the application itself
echo "===================================="
echo "Signing the Ultimaker Cura.app . . ."
echo "===================================="
codesign --entitlements ../../signing/cura.entitlements --verbose --force --deep -o runtime --sign $codesign_identity "Ultimaker Cura.app"

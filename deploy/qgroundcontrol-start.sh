#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"

# hack until icon issue with AppImage is resolved
mkdir -p ~/.icons && cp "${HERE}/indrones-logo.png" ~/.icons

"${HERE}/GroundControlStation" "$@"

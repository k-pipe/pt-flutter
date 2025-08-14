#!/usr/bin/env bash
set -euo pipefail
flutter config --enable-macos-desktop
flutter build macos --release
echo "Built macOS app in build/macos/Build/Products/Release/"

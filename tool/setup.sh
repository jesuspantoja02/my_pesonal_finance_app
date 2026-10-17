#!/usr/bin/env bash
# Genera código (Drift) e instala dependencias. Ejecutar tras clonar o cambiar la BD.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
dart run build_runner build
flutter analyze

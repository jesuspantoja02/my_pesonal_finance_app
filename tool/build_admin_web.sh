#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../admin_web"
if [[ ! -f .env ]]; then
  echo "Crea admin_web/.env desde admin_web/env.example"
  exit 1
fi
npm install
npm run build
echo "Listo: admin_web/dist (despliega con firebase deploy --only hosting)"

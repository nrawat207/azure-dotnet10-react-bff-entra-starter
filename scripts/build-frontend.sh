#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/../src/frontend/starter-web"
npm ci
npm run build
mkdir -p ../../backend/Starter.Bff/wwwroot
cp -R dist/. ../../backend/Starter.Bff/wwwroot/

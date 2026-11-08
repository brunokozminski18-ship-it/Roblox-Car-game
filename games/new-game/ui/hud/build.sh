#!/bin/sh
# Joins the shared spec and the Figma renderer into the plugin's single code.js.
cd "$(dirname "$0")"
mkdir -p figma-plugin
cat spec.js figma.js > figma-plugin/code.js
cat > figma-plugin/manifest.json <<'EOF'
{
  "name": "New Game HUD (LihFolk)",
  "id": "new-game-hud-lihfolk",
  "api": "1.0.0",
  "main": "code.js",
  "editorType": ["figma"],
  "documentAccess": "dynamic-page",
  "networkAccess": { "allowedDomains": ["none"] }
}
EOF
echo "built figma-plugin/code.js"

#!/bin/bash

: <<'COMMENT_BLOCK'
==========================================================================================
🛠️  Flutter Web Setup Script for GitHub Codespaces
------------------------------------------------------------------------------------------
📦 This script:
1. Moves Flutter SDK to a permanent directory (/workspaces/flutter)
2. Adds Flutter to PATH via ~/.bashrc for persistence
3. Enables web support in Flutter
4. Detects Flutter version and fixes index.html script tag
5. Gets dependencies
6. Cleans and rebuilds the Flutter web app
7. Runs the app on web-server (port 8080)

💡 Run this script from your Flutter project root folder.

📌 To run this script:
   chmod +x setup_flutter.sh
   ./setup_flutter.sh

==========================================================================================
COMMENT_BLOCK

# 1. Move Flutter SDK if inside project
if [ -d "flutter" ] && [ ! -d "/workspaces/flutter" ]; then
  echo "📁 Moving Flutter SDK to /workspaces/flutter..."
  mv flutter /workspaces/flutter
fi

# 2. Add Flutter to PATH
if ! grep -q "/workspaces/flutter/bin" ~/.bashrc; then
  echo "🔧 Adding Flutter to PATH..."
  echo 'export PATH="$PATH:/workspaces/flutter/bin"' >> ~/.bashrc
fi
export PATH="$PATH:/workspaces/flutter/bin"

# 3. Verify Flutter installation
echo "🔍 Checking Flutter..."
flutter --version || { echo "❌ Flutter not found in PATH. Exiting."; exit 1; }

# 4. Enable web support
echo "🌐 Enabling web support..."
flutter config --enable-web

# 5. Detect Flutter version
FLUTTER_VERSION=$(flutter --version --machine | grep -oP '"frameworkVersion":\s*"\K[^"]+')
echo "📦 Flutter version detected: $FLUTTER_VERSION"

# 6. Decide script tag
SCRIPT_TAG=""
if [[ "$FLUTTER_VERSION" > "3.10" ]]; then
  SCRIPT_TAG='<script src="flutter_bootstrap.js" async></script>'
else
  SCRIPT_TAG='<script src="main.dart.js" defer></script>'
fi
echo "🔧 Using script tag: $SCRIPT_TAG"

# 7. Fix web/index.html
INDEX_FILE="web/index.html"
if [ -f "$INDEX_FILE" ]; then
  echo "📝 Updating $INDEX_FILE..."
  # Remove any old script tags for dart.js / web_entrypoint
  sed -i '/<script src=.*dart.js.*>/d' "$INDEX_FILE"
  sed -i '/<script src=.*flutter_bootstrap.js.*>/d' "$INDEX_FILE"
  sed -i '/<script src=.*web_entrypoint.dart.js.*>/d' "$INDEX_FILE"
  # Add new one before </body>
  sed -i "s|</body>|  $SCRIPT_TAG\n</body>|" "$INDEX_FILE"
else
  echo "⚠️ No $INDEX_FILE found, skipping HTML update."
fi

# 8. Get dependencies
echo "📚 Running flutter pub get..."
flutter pub get

# 9. Clean build
echo "🧼 Cleaning..."
flutter clean

# 10. Build web
echo "🏗️ Building Flutter web app..."
flutter build web

# 11. Run web server
echo "🚀 Running Flutter app on web-server (port 8080)..."
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0

echo "🌐 Open the PORTS tab in Codespaces and click the globe 🌐 on port 8080."

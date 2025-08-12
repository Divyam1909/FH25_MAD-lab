#!/bin/bash

: <<'COMMENT_BLOCK'
==========================================================================================
🛠️  Flutter Web Setup Script for GitHub Codespaces
------------------------------------------------------------------------------------------
📦 This script:
1. Moves Flutter SDK to a permanent directory (/workspaces/flutter)
2. Adds Flutter to PATH via ~/.bashrc for persistence
3. Enables web support in Flutter
4. Gets Flutter dependencies
5. Launches the app on web-server (port 8080)
6. Opens PORTS tab to preview the running app

💡 Run this script from the root of your project (e.g., /workspaces/FH25_MAD-lab/05-08-25)

📌 Requirements:
- You must have internet in the Codespace.
- Your Flutter project should be valid and contain lib/main.dart and pubspec.yaml.

==========================================================================================
COMMENT_BLOCK

# 1. Move Flutter SDK out of project folder if not already moved
if [ -d "flutter" ] && [ ! -d "/workspaces/flutter" ]; then
  echo "📁 Moving Flutter SDK to /workspaces/flutter..."
  mv flutter /workspaces/flutter
fi

# 2. Add Flutter to PATH in ~/.bashrc if not already added
if ! grep -q "/workspaces/flutter/bin" ~/.bashrc; then
  echo "🔧 Adding Flutter to PATH in ~/.bashrc..."
  echo 'export PATH="$PATH:/workspaces/flutter/bin"' >> ~/.bashrc
fi

# 3. Apply PATH immediately for this session
export PATH="$PATH:/workspaces/flutter/bin"

# 4. Verify Flutter installation
echo "🔍 Checking Flutter version..."
flutter --version || { echo "❌ Flutter not found in PATH. Exiting."; exit 1; }

# 5. Enable web support
echo "🌐 Enabling web support..."
flutter config --enable-web

# 6. Get dependencies
echo "📚 Running flutter pub get..."
flutter pub get

# 7. Clean build (optional but good practice)
echo "🧼 Cleaning previous builds..."
flutter clean

# 8. Prompt to run app
read -p "🚀 Do you want to run the app on web-server now? (y/n): " RUN_NOW
if [ "$RUN_NOW" = "y" ]; then
  echo "🚀 Running Flutter app on web-server (port 8080)..."
  flutter run -d web-server --web-port=8080
  echo "🌐 Open the PORTS tab in Codespaces and click the globe 🌐 on port 8080."
else
  echo "✅ Setup complete. You can run the app anytime with:"
  echo "   flutter run -d web-server --web-port=8080"
fi

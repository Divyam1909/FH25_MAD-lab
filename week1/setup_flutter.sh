#!/bin/bash

: <<'COMMENT_BLOCK'
==========================================================================================
⚡ Flutter Web Manual-Rebuild Menu for GitHub Codespaces
------------------------------------------------------------------------------------------
📌 Features:
  - Build Flutter Web in release mode for fast load times
  - Serve via Python HTTP server
  - Simple menu: Press 'r' to rebuild, 'q' to quit
  - Avoids constant rebuilds on every file change

🔹 How to use:
   chmod +x setup_flutter.sh
   ./setup_flutter.sh
==========================================================================================
COMMENT_BLOCK

# 1. Move Flutter SDK if needed
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

# 3. Verify Flutter
echo "🔍 Checking Flutter..."
flutter --version || { echo "❌ Flutter not found in PATH. Exiting."; exit 1; }

# 4. Enable web
flutter config --enable-web

# 5. Disable service worker for dev
INDEX_FILE="web/index.html"
if [ -f "$INDEX_FILE" ]; then
  echo "⚠️ Disabling service worker..."
  sed -i "s|var serviceWorkerVersion = .*|var serviceWorkerVersion = null;|" "$INDEX_FILE"
fi

# 6. Get deps
flutter pub get

# 7. Function to build & serve
build_and_serve() {
  echo "🏗️ Building Flutter web (release mode)..."
  flutter build web --release > /dev/null 2>&1

  if ! lsof -i:8080 >/dev/null 2>&1; then
    echo "🚀 Starting server on port 8080..."
    cd build/web
    python3 -m http.server 8080 &
    SERVER_PID=$!
    cd ../..
    sleep 2
    if command -v gp preview &>/dev/null; then
      gp preview "$(gp url 8080)"
    else
      echo "🌐 Open the Ports tab and click the globe on port 8080."
    fi
  else
    echo "♻️ Restarting server..."
    kill -9 $(lsof -t -i:8080)
    cd build/web
    python3 -m http.server 8080 &
    SERVER_PID=$!
    cd ../..
  fi
}

# 8. Initial build & serve
build_and_serve

# 9. Menu loop
while true; do
  echo ""
  echo "💡 Press 'r' to rebuild, 'q' to quit"
  read -n 1 key
  echo ""
  case $key in
    r|R) build_and_serve ;;
    q|Q) echo "👋 Quitting..."; kill -9 $(lsof -t -i:8080) 2>/dev/null; exit 0 ;;
    *) echo "❌ Invalid option" ;;
  esac
done
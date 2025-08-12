#!/bin/bash

: <<'COMMENT_BLOCK'
==========================================================================================
⚡ Flutter Web Optimized Auto-Reload Setup for GitHub Codespaces
------------------------------------------------------------------------------------------
📌 Features:
  - Builds Flutter Web in release mode for fast loading
  - Serves via Python HTTP server (fast + lightweight)
  - Watches for changes in lib/ and triggers rebuild
  - Automatically refreshes Codespaces preview tab

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

# 7. Install inotify-tools for watching (if missing)
if ! command -v inotifywait &>/dev/null; then
  echo "📦 Installing inotify-tools for file watching..."
  sudo apt-get update && sudo apt-get install -y inotify-tools
fi

# 8. Build & serve function
build_and_serve() {
  echo "🏗️ Building Flutter web in release mode..."
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
  fi
}

# 9. Initial build
build_and_serve

# 10. Watch for changes in lib/ and rebuild
echo "👀 Watching for changes in lib/..."
inotifywait -m -r -e close_write,modify,create,delete lib/ | while read -r dir events file; do
  echo "♻️ Changes detected in $file — rebuilding..."
  build_and_serve
done

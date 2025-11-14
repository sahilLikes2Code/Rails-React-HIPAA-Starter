#!/bin/bash
# Cleanup script to prepare starter template for git repository
# Removes all build artifacts, dependencies, and generated files

cd "$(dirname "$0")"

echo "🧹 Cleaning up starter template for git repository..."
echo ""

# Remove node_modules
if [ -d "node_modules" ]; then
  echo "Removing node_modules directory..."
  rm -rf node_modules
  echo "✅ node_modules removed"
fi

# Remove .yarn
if [ -d ".yarn" ]; then
  echo "Removing .yarn directory..."
  rm -rf .yarn
  echo "✅ .yarn removed"
fi

# Remove build artifacts (keep .keep file)
if [ -d "app/assets/builds" ]; then
  echo "Removing build artifacts..."
  find app/assets/builds -type f ! -name ".keep" -delete
  echo "✅ Build artifacts removed (kept .keep)"
fi

# Remove log files
if [ -d "log" ]; then
  echo "Removing log files..."
  find log -type f ! -name ".keep" -delete
  echo "✅ Log files removed"
fi

# Remove tmp files
if [ -d "tmp" ]; then
  echo "Removing tmp files..."
  find tmp -type f ! -name ".keep" -delete 2>/dev/null || true
  echo "✅ Tmp files removed"
fi

# Remove .DS_Store files
echo "Removing .DS_Store files..."
find . -name ".DS_Store" -delete 2>/dev/null || true
echo "✅ .DS_Store files removed"

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "The starter template is now ready for git repository."
echo "Dependencies can be regenerated with 'bundle install && yarn install'"


#!/bin/bash
# QA Test Script for Hugo Site
# Run before pushing changes

set -e

SITE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PORT=1314
BASE_URL="http://localhost:$PORT"

echo "🧪 Starting QA Tests..."
echo "================================"

# 1. Build Test
echo ""
echo "📦 [1/4] Build Test..."
cd "$SITE_DIR"
hugo --minify --quiet
if [ $? -eq 0 ]; then
    echo "   ✅ Build successful"
else
    echo "   ❌ Build failed!"
    exit 1
fi

# 2. Start server in background
echo ""
echo "🚀 [2/4] Starting local server..."
hugo server --port $PORT --bind 0.0.0.0 --baseURL $BASE_URL --quiet &
SERVER_PID=$!
sleep 3

# Cleanup function
cleanup() {
    echo ""
    echo "🧹 Cleaning up..."
    kill $SERVER_PID 2>/dev/null || true
}
trap cleanup EXIT

# 3. Link Tests
echo ""
echo "🔗 [3/4] Testing page links..."

PAGES=("/" "/about/" "/experience/" "/projects/" "/posts/" "/contact/")
ALL_OK=true

for page in "${PAGES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$page")
    if [ "$STATUS" = "200" ]; then
        echo "   ✅ $page -> $STATUS"
    else
        echo "   ❌ $page -> $STATUS"
        ALL_OK=false
    fi
done

# 4. Menu Links Test (extract from HTML and verify)
echo ""
echo "🍔 [4/4] Testing menu navigation..."

# Get menu links from homepage
MENU_LINKS=$(curl -s "$BASE_URL/" | grep -oP 'href="[^"]*"' | grep -E "(about|experience|projects|posts|contact)" | sed 's/href="//g' | sed 's/"//g' | sort -u)

for link in $MENU_LINKS; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$link")
    if [ "$STATUS" = "200" ]; then
        echo "   ✅ $link -> $STATUS"
    else
        echo "   ❌ $link -> $STATUS"
        ALL_OK=false
    fi
done

# Summary
echo ""
echo "================================"
if [ "$ALL_OK" = true ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed!"
    exit 1
fi

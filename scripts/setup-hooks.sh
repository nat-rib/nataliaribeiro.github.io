#!/bin/bash
# Setup git hooks for this repository

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🔧 Setting up git hooks..."
git config core.hooksPath .githooks

echo "✅ Git hooks configured!"
echo ""
echo "Pre-commit hook will now run QA tests before each commit."
echo "To skip (not recommended): git commit --no-verify"

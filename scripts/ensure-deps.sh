#!/bin/bash
set -e

RUBY_DIR="${CLAUDE_PLUGIN_ROOT}/data_sources/ruby"
MARKER="${RUBY_DIR}/vendor/.installed"

if ! command -v ruby &> /dev/null; then
  echo "[agent-seo] Ruby not found. Core commands (research, write, humanize, fact-check) work without it. Analysis tools (keyword density, readability, SEO quality, scrub) require Ruby 3.0+."
  exit 0
fi

if ! command -v bundle &> /dev/null; then
  echo "[agent-seo] Bundler not found. Install with: gem install bundler"
  exit 0
fi

cd "$RUBY_DIR"

if [ ! -f "$MARKER" ] || [ "Gemfile" -nt "$MARKER" ] || [ "Gemfile.lock" -nt "$MARKER" ]; then
  echo "[agent-seo] Installing Ruby dependencies..."
  bundle install --quiet --path vendor/bundle
  touch "$MARKER"
  echo "[agent-seo] Ruby dependencies installed."
fi

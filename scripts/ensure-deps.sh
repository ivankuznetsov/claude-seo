#!/bin/bash
set -e

RUBY_DIR="${CLAUDE_PLUGIN_ROOT}/data_sources/ruby"

if ! command -v ruby &> /dev/null; then
  echo "Warning: Ruby not found. SEO analysis tools require Ruby 3.0+." >&2
  exit 0
fi

if ! command -v bundle &> /dev/null; then
  echo "Warning: Bundler not found. Run: gem install bundler" >&2
  exit 0
fi

cd "$RUBY_DIR"

if [ ! -d "vendor/bundle" ] || [ "Gemfile.lock" -nt "vendor/bundle" ]; then
  bundle install --quiet --path vendor/bundle 2>/dev/null
fi
